require_relative 'questionrelation'
require_relative 'model'


class User < ModelBase
  attr_reader :id
  attr_accessor :f_name, :l_name

  def initialize(options)
    @id = options['id']
    @l_name = options['l_name']
    @f_name = options['f_name']
  end

  def followed_questions
    QuestionFollow.followed_questions_for_user_id(@id)
  end

  def liked_questions
    QuestionLike.liked_questions_for_user_id(@id)
  end

  def average_karma
    data = QuestionDBConnection.instance.execute(<<-SQL, @id)
      SELECT
        count(DISTINCT questions.id) as num_questions,
        count(question_likes.question_id) as num_likes
      FROM
        questions
      LEFT OUTER JOIN
        question_likes ON questions.id = question_likes.question_id
      WHERE
        questions.user_id = ?
    SQL
    data = data.first
    num_questions = data['num_questions']
    num_likes = data['num_likes']
    return 0 if num_questions == 0
    num_likes.to_f/num_questions
  end

  def create
    QuestionDBConnection.instance.execute(<<-SQL, @f_name, @l_name)
      INSERT INTO
        users(f_name, l_name)
      VALUES
        (?,?)
    SQL
    @id = QuestionDBConnection.instance.last_insert_row_id
  end

  def update
    QuestionDBConnection.instance.execute(<<-SQL, @f_name, @l_name, @id)
      UPDATE
        users
      SET
        f_name = ?, l_name = ?
      WHERE
        id = ?
    SQL
    @id = QuestionDBConnection.instance.last_insert_row_id
  end

end
