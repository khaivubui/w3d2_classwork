class Question
  def self.all
    questions = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT * FROM questions
    SQL

    questions.map { |question| Question.new(question) }
  end

  def self.find_by_id(id)
    questions = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT * FROM questions WHERE id = ?
    SQL
    Question.new(questions.first)
  end

  def self.find_by_author_id(author_id)
    questions = QuestionsDatabase.instance.execute(<<-SQL, author_id)
      SELECT * FROM questions WHERE author_id = ?
    SQL

    questions.map { |question| Question.new(question) }
  end

  def self.most_followed(n)
    QuestionFollow.most_followed_questions(n)
  end

  def self.most_liked(n)
    QuestionLike.most_liked_questions(n)
  end

  attr_accessor :title, :body, :author_id

  def initialize(options)
    @id = options["id"]
    @title = options["title"]
    @body = options["body"]
    @author_id = options["author_id"]
  end

  def author
    authors = QuestionsDatabase.instance.execute(<<-SQL, @author_id)
      SELECT * FROM users WHERE id = ?
    SQL

    User.new(authors.first)
  end

  def replies
    Reply.find_by_question_id(@id)
  end

  def followers
    QuestionFollow.followers_for_question_id(@id)
  end

  def likers
    QuestionLike.likers_for_question_id(@id)
  end

  def num_likes
    QuestionLike.num_likes_for_question_id(@id)
  end
end
