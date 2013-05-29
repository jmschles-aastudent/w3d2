require 'sqlite3'
require 'singleton'
require_relative 'user.rb'
require_relative 'reply.rb'
require_relative 'question_like.rb'

class QuestionsDatabase < SQLite3::Database
  DATABASE = 'questionsdb'

  include Singleton

  def initialize
    super(DATABASE)
    @results_as_hash = true
  end
end

class Question
  attr_accessor :title, :body, :author_id
  attr_reader :id

  def self.find_by_id(id)
    query = <<-SQL
    SELECT *
    FROM questions
    WHERE id=?
    SQL

    Question.new QuestionsDatabase.instance.get_first_row(query, id)
  end

  def self.find_by_author_id(author_id)
    query = <<-SQL
    SELECT *
    FROM questions
    WHERE author_id=?
    SQL

    QuestionsDatabase.instance.execute(query, author_id).map do |rec|
      Question.new(rec)
    end
  end

  def self.most_followed(n)
    QuestionFollwer.most_followed_questions(n)
  end

  def self.most_liked(n)
    QuestionLike.most_liked_questions(n)
  end

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @author_id = options['author_id']
  end

  def save
    update = <<-SQL
    UPDATE questions
    SET title=?, body=?, author_id=?
    WHERE id=?
    SQL

    insert = <<-SQL
    INSERT INTO questions ('title', 'body', 'author_id')
    VALUES (?, ?, ?)
    SQL

    if @id
      QuestionsDatabase.instance.execute(update, @title, @body, @author_id, @id)
    else
      QuestionsDatabase.instance.execute(insert, @title, @body, @author_id)
      @id = QuestionsDatabase.instance.last_insert_row_id
    end
  end

  def likers
    QuestionLike.likers_for_question_id(@id)
  end

  def num_likes
    QuestionLike.num_likes_for_question_id(@id)
  end

  def followers
    QuestionFollower.followers_for_question_id(@id)
  end

  def author
    query = <<-SQL
    SELECT *
    FROM users
    WHERE id=?
    SQL

    User.new QuestionsDatabase.instance.get_first_row(query, @author_id)
  end

  def replies
    query = <<-SQL
    SELECT *
    FROM replies
    WHERE question_id=?
    SQL

    QuestionsDatabase.instance.execute(query, @id).map do |rec|
      Reply.new(rec)
    end
  end
end

class QuestionFollower
  attr_reader :question_id, :follower_id, :id

  def self.find_by_id(id)
    query = <<-SQL
    SELECT *
    FROM question_followers
    WHERE id=?
    SQL

    QuestionFollower.new QuestionsDatabase.instance.get_first_row(query, id)
  end

  def self.followers_for_question_id(question_id)
    query = <<-SQL
    SELECT users.id, users.fname, users.lname
    FROM users
    JOIN question_followers
    ON question_followers.follower_id=users.id
    WHERE question_followers.question_id=?
    SQL

    QuestionsDatabase.instance.execute(query, question_id).map do |rec|
      User.new(rec)
    end
  end

  def self.followed_questions_for_user_id(user_id)
    query = <<-SQL
    SELECT q.id, q.title, q.body, q.author_id
    FROM questions AS q
    JOIN question_followers AS qf
    ON qf.question_id=q.id
    WHERE qf.follower_id=?
    SQL

    QuestionsDatabase.instance.execute(query, user_id).map do |rec|
      Question.new(rec)
    end
  end

  def self.most_followed_questions(n)
    query = <<-SQL
    SELECT q.id, q.title, q.body, q.author_id
    FROM question_followers
    JOIN questions q
    ON q.id = question_followers.question_id
    GROUP BY question_followers.question_id
    ORDER BY COUNT(*) DESC
    LIMIT ?
    SQL

    QuestionsDatabase.instance.execute(query, n).map do |rec|
      Question.new(rec)
    end
  end

  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @follower_id = options['follower_id']
  end
end

class QuestionLike
  attr_reader :user_id, :question_id, :id

  def self.find_by_id(id)
    query = <<-SQL
    SELECT *
    FROM question_likes
    WHERE id=?
    SQL

    QuestionLike.new QuestionsDatabase.instance.get_first_row(query, id)
  end

  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end
end























