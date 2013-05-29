require_relative 'questions_database'

class Tag

  def self.most_popular
  #   query = <<-SQL
  #   SELECT questions.id, question_tags.tag_id, COUNT(*)
  #   FROM questions
  #   JOIN question_tags
  #   ON questions.id = question_tags.question_id
  #   LEFT OUTER JOIN question_likes
  #   ON questions.id = question_likes.question_id
  #   GROUP BY questions.id, question_tags.tag_id
  #   ORDER BY question_tags.tag_id, COUNT(*) DESC
  #   SQL
  # end

    tag_list_query = <<-SQL
    SELECT id
    FROM tags
    SQL

    most_popular_for_tag = <<-SQL
    SELECT q.id, q.title, q.body, q.author_id
    FROM questions q
    LEFT OUTER JOIN question_tags qt
    ON q.id = qt.question_id
    LEFT OUTER JOIN question_likes ql
    ON q.id = ql.question_id
    WHERE qt.tag_id = ?
    GROUP BY q.id
    ORDER BY COUNT(ql.question_id) DESC
    LIMIT 1
    SQL

    tag_list = QuestionsDatabase.instance.execute(tag_list_query)
    most_popular_questions = Hash.new

    tag_list.each do |tag|
      tag_id = tag["id"]
      q = QuestionsDatabase.instance.get_first_row(most_popular_for_tag, tag_id)

      unless q.nil?
        question = Question.new(q)
        most_popular_questions[tag_id] = question
      end
    end

    most_popular_questions
  end
end