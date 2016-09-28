require_relative 'model'
require_relative 'user'


class Question < ModelBase
  attr_reader :id, :user_id
  attr_accessor :body, :title

  def initialize(options)
    @id = options['id']
    @body = options['body']
    @title = options['title']
    @user_id = options['user_id']
  end

  def followers
    QuestionFollow.followers_for_question_id(@id)
  end

  def self.most_followed(n)
    QuestionFollow.most_followed_questions(n)
  end

  def likers
    QuestionLike.likers_for_question_id(@id)
  end

  def num_likes
    QuestionLike.num_likes_for_question_id(@id)
  end

  def create
    QuestionDBConnection.instance.execute(<<-SQL, @body, @title, @user_id)
      INSERT INTO
        questions(body, title, user_id)
      VALUES
        (?,?,?)
    SQL
    @id = QuestionDBConnection.instance.last_insert_row_id
  end

  def update
    QuestionDBConnection.instance.execute(<<-SQL, @body, @title, @user_id, @id)
      UPDATE
        questions
      SET
        body = ?, title = ?, user_id = ?
      WHERE
        id = ?
    SQL
    @id = QuestionDBConnection.instance.last_insert_row_id
  end

  class QuestionRelation < ModelBase

    attr_reader :question_id, :user_id

    def initialize(options)
      @question_id = options['question_id']
      @user_id = options['user_id']
    end

  end

  class QuestionFollow < QuestionRelation
    def self.followed_questions_for_user_id(user_id)
      data = QuestionDBConnection.instance.execute(<<-SQL, user_id)
        SELECT
          questions.*
        FROM
          questions
        JOIN
          question_follows ON question_follows.question_id = questions.id
        WHERE
          question_follows.user_id = ?
      SQL
      data.map {|datum| Question.new(datum)}
    end

    def self.followers_for_question_id(question_id)
      data = QuestionDBConnection.instance.execute(<<-SQL, question_id)
        SELECT
          users.*
        FROM
          users
        JOIN
          question_follows ON question_follows.user_id = users.id
        WHERE
          question_follows.question_id = ?
      SQL
      data.map {|datum| User.new(datum)}
    end

    def self.most_followed_questions(n)
      data = QuestionDBConnection.instance.execute(<<-SQL, n)
        SELECT
          questions.*
        FROM
          questions
        LEFT OUTER JOIN
          question_follows ON question_follows.question_id = questions.id
        GROUP BY questions.id
        ORDER BY count(question_follows.question_id) DESC
        LIMIT ?
      SQL
      data.map {|datum| Question.new(datum)}
    end


  end

  class QuestionLike < QuestionRelation
    def self.likers_for_question_id(question_id)
      data = QuestionDBConnection.instance.execute(<<-SQL, question_id)
        SELECT
          users.*
        FROM
          users
        JOIN
          question_likes ON users.id = question_likes.user_id
        WHERE question_likes.question_id = ?
      SQL
      data.map {|datum| User.new(datum)}
    end

    def self.num_likes_for_question_id(question_id)
      data = QuestionDBConnection.instance.execute(<<-SQL, question_id)
        SELECT
          count(*) as num_likes
        FROM
          users
        JOIN
          question_likes ON users.id = question_likes.user_id
        WHERE question_likes.question_id = ?
      SQL
      data.first['num_likes']
    end

    def self.liked_questions_for_user_id(user_id)
      data = QuestionDBConnection.instance.execute(<<-SQL, user_id)
        SELECT
          questions.*
        FROM
          questions
        JOIN
          question_likes ON question_likes.question_id = questions.id
        WHERE
          question_likes.user_id = ?
      SQL
      data.map {|datum| Question.new(datum)}
    end

    def self.most_liked_questions(n)
      data = QuestionDBConnection.instance.execute(<<-SQL, n)
        SELECT
          questions.*
        FROM
          questions
        LEFT OUTER JOIN
          question_likes ON question_likes.question_id = questions.id
        GROUP BY questions.id
        ORDER BY count(question_likes.question_id) DESC
        LIMIT ?
      SQL
      data.map {|datum| Question.new(datum)}
    end

  end
end
