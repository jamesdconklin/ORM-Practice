require_relative 'model'

class Reply < ModelBase
  attr_reader :id, :parent_id, :user_id, :question_id
  attr_accessor :body

  def initialize(options)
    @id = options['id']
    @body = options['body']
    @user_id = options['user_id']
    @parent_id = options['parent_id']
    @question_id = options['question_id']
  end

end
