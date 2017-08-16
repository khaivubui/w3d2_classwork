class QuestionLike
  def self.likers_for_question_id(question_id)
    likers = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT users.*
      FROM question_likes
      JOIN users ON users.id = question_likes.liker_id
      WHERE question_likes.question_id = ?
    SQL

    return nil if likers.empty?
    likers.map { |liker| User.new(liker) }
  end

  def self.num_likes_for_question_id(question_id)
    num_likes = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT COUNT(*) AS num_likes
      FROM question_likes
      WHERE question_id = ?
      GROUP BY question_id
    SQL

    num_likes.first["num_likes"].to_i
  end

  def self.liked_questions_for_user_id(user_id)
    questions = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT questions.*
      FROM question_likes
      JOIN questions
      ON questions.id = question_likes.question_id
      WHERE liker_id = ?
    SQL

    questions.map { |question| Question.new(question) }
  end

  def self.most_liked_questions(n)
    questions = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT questions.*
      FROM questions
      JOIN (
        SELECT question_id
        FROM question_likes
        GROUP BY question_id
        ORDER BY COUNT(liker_id) DESC
        LIMIT ?
      ) AS most_liked_questions
      ON questions.id = most_liked_questions.question_id
    SQL

    return nil if questions.empty?
    questions.map { |question| Question.new(question) }
  end
end
