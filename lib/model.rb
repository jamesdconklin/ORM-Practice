require 'sqlite3'
require 'singleton'
require 'byebug'

class QuestionDBConnection < SQLite3::Database
  include Singleton

  def initialize
    super('lib/questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end

end

class ModelBase
  TABLE_MAPPING = {
    "User" => "users",
    "Reply" => "replies",
    "Question" => "questions",
    "QuestionFollow" => "question_follows",
    "QuestionLike" => "question_likes"
  }
  attr_reader :id

  def initialize
  end

  def self.strip_atmark(vars)
    vars.map do |sym|
      sym.to_s[1..-1].to_sym
    end
  end

  def create
    table = TABLE_MAPPING[self.class.to_s]
    symbols = ModelBase.strip_atmark(instance_variables)
    symbols.delete(:id)
    vals = symbols.map {|sym| send(sym)}


    QuestionDBConnection.instance.execute(<<-SQL, *vals)
      INSERT INTO
        #{table}(#{symbols.join(', ')})
      VALUES
        (#{symbols.map {'?'}.join(', ')})
    SQL
    @id = QuestionDBConnection.instance.last_insert_row_id
  end

  def update
    symbols = ModelBase.strip_atmark(instance_variables)
    symbols << symbols.delete(:id)
    vals = symbols.map {|sym| send(sym)}
    vals << @id
    QuestionDBConnection.instance.execute(<<-SQL, *vals)
      UPDATE
        #{table}
      SET
        #{symbols.map {|sym| "#{sym} = ?"}.join(', ')}
      WHERE
        id = ?
    SQL
    @id = QuestionDBConnection.instance.last_insert_row_id
  end

  def save
    if @id.nil?
      create
    else
      update
    end
  end

  def self.where_clause(opt)
    vals = []
    raw = opt.map do |k,v|
      vals << v
      "#{k} = ?"
    end
    return ['', []] if vals.empty?
    ["WHERE #{raw.join(" AND ")}", vals]
  end

  def self.all
    self.select_where({})
  end

  def self.select_where(opt)
    wc = self.where_clause(opt)
    table = TABLE_MAPPING[self.to_s]

    data = QuestionDBConnection.instance.execute(<<-SQL, *wc.last)
      SELECT *
      FROM #{table}
      #{wc.first}
    SQL
    data.map {|datum| self.new(datum)}
  end

  def self.method_missing(*args)
    params = args.first.to_s.dup
    get_by = params.slice!('get_by_')
    find_by = params.slice!('find_by_')
    params = params.split('_and_')
    raise "Bad Method: #{args.first}" unless get_by.nil? ^ find_by.nil?
    where_dict = {}

    params.zip(args.drop(1)).each {|col, val| where_dict[col] = val}

    rows = self.select_where(where_dict)
    return rows if get_by.nil?
    rows.first
  end

end
