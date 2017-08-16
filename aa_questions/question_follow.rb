class QuestionFollow
  def self.followers_for_question_id(question_id)
    followers = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT users.*
      FROM question_follows
      JOIN users
      ON question_follows.follower_id = users.id
      WHERE question_follows.question_id = ?
    SQL

    return nil if followers.empty?
    followers.map { |follower| User.new(follower) }
  end

  def self.followed_questions_for_user_id(user_id)
    questions = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT questions.*
      FROM question_follows
      JOIN questions
      ON question_follows.question_id = questions.id
      WHERE question_follows.follower_id = ?
    SQL

    return nil if questions.empty?
    questions.map { |question| Question.new(question) }
  end

  def self.most_followed_questions(n)
    questions = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT questions.*
      FROM questions
      JOIN (
        SELECT question_id
        FROM question_follows
        GROUP BY question_id
        ORDER BY COUNT(follower_id) DESC
        LIMIT ?
      ) AS most_followed_questions
      ON questions.id = most_followed_questions.question_id
    SQL

    return nil if questions.empty?
    questions.map { |question| Question.new(question) }
  end
end
