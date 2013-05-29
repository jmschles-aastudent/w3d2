require 'sqlite3'
require 'singleton'

class QuestionsDatabase < SQLite3::Database
  DATABASE = 'questionsdb'

  include Singleton

  def initialize
    super(DATABASE)
    @results_as_hash = true
  end
end