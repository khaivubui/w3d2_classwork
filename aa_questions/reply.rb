class Reply
  def self.all
    replies = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT * FROM replies
    SQL

    replies.map { |reply| Reply.new(reply) }
  end

  def self.find_by_id(id)
    replies = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT * FROM replies WHERE id = ?
    SQL
    Reply.new(replies.first)
  end

  def self.find_by_question_id(question_id)
    replies = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT * FROM replies WHERE question_id = ?
    SQL
    replies.map { |reply| Reply.new(reply) }
  end

  def self.find_by_user_id(user_id)
    replies = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT * FROM replies WHERE user_id = ?
    SQL

    replies.map { |reply| Reply.new(reply) }
  end

  attr_accessor :question_id, :parent_reply_id, :reply_body, :user_id

  def initialize(options)
    @id = options["id"]
    @question_id = options["question_id"]
    @parent_reply_id = options["parent_reply_id"]
    @reply_body = options["reply_body"]
    @user_id = options["user_id"]
  end

  def author
    authors = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT * FROM users WHERE id = ?
    SQL
    User.new(authors.first)
  end

  def question
    questions = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT * FROM questions WHERE id = ?
    SQL
    Question.new(questions.first)
  end

  def parent_reply
    replies = QuestionsDatabase.instance.execute(<<-SQL, parent_reply_id)
      SELECT * FROM replies WHERE id = ?
    SQL

    return nil unless replies.length > 0
    Reply.new(replies.first)
  end

  def child_replies
    replies = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT * FROM replies WHERE parent_reply_id = ?
    SQL

    return nil unless replies.length > 0

    replies.map { |reply| Reply.new(reply) }
  end

end
