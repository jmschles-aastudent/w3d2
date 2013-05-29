require_relative 'questions_database.rb'
require_relative 'user.rb'

class QuestionLike

  def self.likers_for_question_id(question_id)
    query = <<-SQL
    SELECT user.id, user.fname, user.lname
    FROM users
    JOIN question_likes
    ON users.id = question_likes.user_id
    WHERE question_likes.question_id = ?
    SQL

    QuestionsDatabase.instance.execute(query, question_id).map do |rec|
      User.new(rec)
    end
  end

  def self.num_likes_for_question_id(question_id)
    query = <<-SQL
    SELECT COUNT(*)
    FROM question_likes
    JOIN questions
    ON questions.id = question_likes.question_id
    WHERE questions.id = ?
    GROUP BY questions.id
    SQL

    QuestionsDatabase.instance.get_first_row(query, question_id)["COUNT(*)"]
  end

  def self.liked_questions_for_user_id(user_id)
    query = <<-SQL
    SELECT q.id, q.title, q.body, q.author_id
    FROM questions q
    JOIN question_likes
    ON q.id = question_likes.question_id
    WHERE question_likes.user_id = ?
    SQL

    QuestionsDatabase.instance.execute(query, user_id).map do |rec|
      Question.new(rec)
    end
  end

  def self.most_liked_questions(n)
    query = <<-SQL
    SELECT q.id, q.title, q.body, q.author_id
    FROM questions q
    JOIN question_likes
    ON q.id = question_likes.question_id
    GROUP BY q.id
    ORDER BY COUNT(*) DESC
    LIMIT ?
    SQL

    QuestionsDatabase.instance.execute(query, n).map do |rec|
      Question.new(rec)
    end
  end

  def initialize(options)
    @id = id
    @user_id = options['user_id']
    @question_id = options['question_id']
  end
end