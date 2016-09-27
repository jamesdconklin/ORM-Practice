require_relative 'user'
require_relative 'question'


class QuestionRelation < ModelBase

  attr_reader :question_id, :user_id, :question, :author

  def initialize(options)
    question_id = options['question_id']
    user_id = options['user_id']
  end

  def question_id=(obj)
    raise "question_id must be integer" unless obj.class == Fixnum
    @question_id = obj
    @question = Question.get_by_id(obj)
  end

  def user_id=(obj)
    raise "user_id must be integer" unless obj.class == Fixnum
    @user_id = obj
    @author = User.get_by_id(obj)
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
