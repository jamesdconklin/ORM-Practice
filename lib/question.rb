require 'model'
require 'questionrelation'


class Question < ModelBase
  attr_reader :id, :user_id
  attr_accessor :body, :title, :author

  def initialize(options)
    @id = options['id']
    @body = options['body']
    @title = options['title']
    user_id = options['user_id']
  end

  def user_id=(obj)
    raise "user_id must be an integer." unless obj.is_a?(Fixnum)
    @user_id = obj
    @author = User.get_by_id(@id)
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

end
