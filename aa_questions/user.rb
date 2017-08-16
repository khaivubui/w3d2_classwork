class User
  def self.all
    users = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT * FROM users
    SQL

    users.map { |user| User.new(user) }
  end

  def self.find_by_id(id)
    users = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT * FROM users WHERE id = ?
    SQL
    User.new(users.first)
  end

  def self.find_by_name(fname, lname)
    users = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT * FROM users WHERE fname = ? AND lname = ?
    SQL

    User.new(users.first)
  end

  attr_accessor :fname, :lname

  def initialize(options)
    @id = options["id"]
    @fname = options["fname"]
    @lname = options["lname"]
  end

  def update
    QuestionsDatabase.instance.execute(<<-SQL, @fname, @lname, @id)
      UPDATE
        users
      SET
        fname = ?, lname = ?
      WHERE
        id = ?
    SQL
  end

  def save
    return update if @id
    QuestionsDatabase.instance.execute(<<-SQL, @fname, @lname)
      INSERT INTO
        users (fname, lname)
      VALUES
        (?, ?)
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def authored_questions
    Question.find_by_author_id(@id)
  end

  def authored_replies
    Reply.find_by_user_id(@id)
  end

  def followed_questions
    QuestionFollow.followed_questions_for_user_id(@id)
  end

  def liked_questions
    QuestionLike.liked_questions_for_user_id(@id)
  end

  def average_karma
    data = QuestionsDatabase.instance.execute(<<-SQL, @id)

    SELECT
      questions_per_user.author_id,
      CAST(questions_per_user.total_questions_per_user AS FLOAT) /
      likes_per_user.total_likes_per_user AS average_likes_per_user
    FROM
      -- Get number of questions asked per user
      ( SELECT author_id, COUNT(*) AS total_questions_per_user
      FROM questions
      GROUP BY author_id
      ) AS questions_per_user
    JOIN
      -- Get total number of likes per user
      ( SELECT author_id, COUNT(*) AS total_likes_per_user
      FROM question_likes
      JOIN questions
      ON questions.id = question_likes.question_id
      GROUP BY questions.author_id
      ) AS likes_per_user
    ON questions_per_user.author_id = likes_per_user.author_id

    WHERE questions_per_user.author_id = ?

    SQL

    data.first["average_likes_per_user"]
  end
end
