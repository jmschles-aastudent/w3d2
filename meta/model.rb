require_relative 'questions_database'

class Model
  @column_names = []

  def self.table_name
    raise NotImplementedError
  end

  def self.find(id)
    query = <<-SQL
    SELECT *
    FROM #{self.table_name}
    WHERE id=?
    SQL

    self.new(QuestionsDatabase.instance.get_first_row(query, id))
  end

  def self.all
    query = <<-SQL
    SELECT *
    FROM #{self.table_name}
    SQL

    QuestionsDatabase.instance.execute(query).map do |rec|
      self.new(rec)
    end
  end

  def self.column_names
    @column_names
  end

  def save
    cols = self.class.column_names
    cols_joined = cols.join(', ')

    vals = self.class.column_names.map do |col|
      val = self.send(col)
      p val
      # val = "'#{val}'" if val.is_a? String
      "#{self.send(col)}"
    end

    vals_joined = vals.join(', ')

    cols_and_vals = [cols, vals].transpose.map do |pair|
      pair.join('=')
    end.join(', ')

    insert = <<-SQL
    INSERT INTO #{self.class.table_name} (#{cols_joined})
    VALUES (#{vals_joined})
    SQL

    update = <<-SQL
    UPDATE #{self.class.table_name}
    SET #{cols_and_vals}
    WHERE id=?
    SQL

    puts update
  end

  protected

  def self.attr_accessible(*column_names)
    @column_names ||= []
    column_names.each do |column_name|
      @column_names << column_name unless @column_names.include? column_name
      class_eval("def #{column_name}; @#{column_name}; end")
      class_eval("def #{column_name}=(val); @#{column_name} = val; end")
    end
  end
end

class User < Model
  attr_accessible :fname, :lname

  def self.table_name
    'users'
  end

  def initialize(options = {})
    @fname = options['fname']
    @lname = options['lname']
  end
end