require 'sqlite3'
require 'singleton'

class QuestionDBConnection < SQLite3::Database
  include Singleton

  def initialize
    super('lib/questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end

end

class ModelBase
  @@table_mapping = {
    "User" => "users",
    "Reply" => "replies",
    "Question" => "questions",
    "QuestionFollow" => "question_follows",
    "QuestionLike" => "question_likes"
  }
  attr_reader :id

  def initialize
  end

  def save
    if @id.nil?
      create
    else
      update
    end
  end

  def self.method_missing(*args)
    params = args.first.to_s.dup
    get_by = params.slice!('get_by_')
    find_by = params.slice!('find_by_')
    params = params.split('_and_')
    raise "bad method" unless get_by.nil? ^ find_by.nil?

    where_clause = params.map {|pm| "#{pm} = ?"}.join(" AND ")

    table = @@table_mapping[self.to_s]
    data = QuestionDBConnection.instance.execute(<<-SQL, *args.drop(1))
      SELECT *
      FROM #{table}
      WHERE #{where_clause}
    SQL
    rows = data.map {|datum| self.new(datum)}
    return rows if get_by.nil?
    rows.first
  end

end
