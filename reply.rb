require_relative 'questions_database.rb'
require_relative 'user.rb'

class Reply
  attr_reader :body, :author_id, :question_id, :parent_reply_id, :id

  def self.find_by_id(id)
    query = <<-SQL
    SELECT *
    FROM replies
    WHERE id=?
    SQL

    Reply.new QuestionsDatabase.instance.get_first_row(query, id)
  end

  def self.find_by_question_id(question_id)
    query = <<-SQL
    SELECT *
    FROM replies
    WHERE question_id=?
    SQL

    QuestionsDatabase.instance.execute(query, question_id).map do |rec|
      Reply.new(rec)
    end
  end

  def self.find_by_user_id(user_id)
    query = <<-SQL
    SELECT *
    FROM replies
    WHERE user_id=?
    SQL

    QuestionsDatabase.instance.execute(query, user_id).map do |rec|
      Reply.new(rec)
    end
  end

  def initialize(options)
    @id = options['id']
    @body = options['body']
    @author_id = options['author_id']
    @question_id = options['question_id']
    @parent_reply_id = options['parent_reply_id']
  end

  def save

    update = <<-SQL
    UPDATE replies
    SET body = ?, author_id = ?, question_id = ?, parent_reply_id = ?
    WHERE id = ?
    SQL

    insert = <<-SQL
    INSERT INTO replies ('body', 'author_id', 'question_id', 'parent_reply_id')
    VALUES (?, ?, ?, ?)
    SQL

    if @id
      QuestionsDatabase.instance.execute(update, @body, @author_id, @question_id, @parent_reply_id, @id)
    else
      QuestionsDatabase.instance.execute(insert, @body, @author_id, @question_id, @parent_reply_id)
      @id = QuestionsDatabse.instance.last_insert_row_id
    end

  end

  def author
    query = <<-SQL
    SELECT *
    FROM users
    WHERE id=?
    SQL

    User.new QuestionsDatabase.instance.get_first_row(query, @author_id)
  end

  def question
    query = <<-SQL
    SELECT *
    FROM questions
    WHERE id=?
    SQL

    Question.new QuestionsDatabase.instance.get_first_row(query, @question_id)
  end

  def parent_reply
    query = <<-SQL
    SELECT *
    FROM replies
    WHERE id=?
    SQL

    Reply.new QuestionsDatabase.instance.get_first_row(query, @parent_reply_id)
  end

  def child_replies
    query = <<-SQL
    SELECT child.id,
           child.body,
           child.author_id,
           child.question_id,
           child.parent_reply_id
    FROM replies parent
    JOIN replies child
    ON parent.id=child.parent_reply_id
    WHERE parent.id=?
    SQL

    QuestionsDatabase.instance.execute(query, @id).map do |rec|
      Reply.new(rec)
    end
  end
end