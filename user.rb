require_relative 'questions_database.rb'
require_relative 'reply.rb'
require_relative 'question_like.rb'

class User
  attr_reader :fname, :lname, :id

  def self.find_by_name(fname, lname)
    query = <<-SQL
    SELECT *
    FROM users
    WHERE fname=?
    AND lname=?
    SQL

    User.new QuestionsDatabase.instance.get_first_row(query, fname, lname)
  end

  def self.find_by_id(id)
    query = <<-SQL
    SELECT *
    FROM users
    WHERE id=?
    SQL

    User.new QuestionsDatabase.instance.get_first_row(query, id)
  end

  def initialize(options = {})
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def save
    update = <<-SQL
    UPDATE users
    SET fname=?, lname=?
    WHERE id = ?
    SQL

    insert = <<-SQL
    INSERT INTO users ('fname', 'lname')
    VALUES (?, ?)
    SQL

    if @id
      QuestionsDatabase.instance.execute(update, @fname, @lname, @id)
    else
      QuestionsDatabase.instance.execute(insert, @fname, @lname)
      @id = QuestionsDatabase.instance.last_insert_row_id
    end

  end

  def average_karma
    query = <<-SQL
    SELECT
      CAST(COUNT(DISTINCT q) AS float) / COUNT(l) AS avg
    FROM
      (SELECT
         questions.id AS q,
         question_likes.user_id AS l
      FROM
        questions
      LEFT OUTER JOIN
        question_likes
      ON
        questions.id = question_likes.question_id
      WHERE
        questions.author_id = ?)
    SQL

    QuestionsDatabase.instance.get_first_row(query, @id)['avg']
  end

  def followed_questions
    QuestionsFollower.followed_questions_for_user_id(@id)
  end

  def liked_questions
    QuestionLike.liked_questions_for_user_id(@id)
  end

  def authored_questions
    query = <<-SQL
    SELECT *
    FROM questions
    WHERE author_id=?
    SQL

    QuestionsDatabase.instance.execute(query, @id).map do |rec|
      Question.new(rec)
    end
  end

  def authored_replies
    query = <<-SQL
    SELECT *
    FROM replies
    WHERE author_id=?
    SQL

    QuestionsDatabase.instance.execute(query, @id).map do |rec|
      Reply.new(rec)
    end
  end

  # def save
  #   if id.nil?
  #     QuestionsDatabase.instance.execute("")
  # end
end