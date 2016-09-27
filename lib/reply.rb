require_relative 'model'
require_relative 'user'
require_relative 'question'

class Reply < ModelBase
  attr_reader :id, :parent_id, :user_id, :question_id
  attr_accessor :body, :author, :parent_reply, :question

  def initialize(options)
    @id = options['id']
    @body = options['body']
    user_id = options['user_id']
    unless options['parent_id'].nil?
      parent_id = options['parent_id']
    end
    question_id = options['question_id']
  end

  def user_id=(obj)
    #TODO: These methods can enforce FKey constraints.
    raise "user_id must be an integer." unless obj.is_a?(Fixnum)
    @user_id = obj
    @author = User.get_by_id(obj)
  end

  def parent_id=(obj)
    raise "parent_id must be an integer." unless obj.is_a?(Fixnum)
    @parent_id = obj
    @parent_reply = Reply.get_by_id(obj)
  end

  def question_id=(obj)
    raise "user_id must be an integer." unless obj.is_a?(Fixnum)
    @question_id = obj
    @question = Question.get_by_id(obj)
  end

end
