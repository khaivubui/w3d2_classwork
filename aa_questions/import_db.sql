DROP TABLE IF EXISTS users;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname TEXT NOT NULL,
  lname TEXT NOT NULL
);

DROP TABLE IF EXISTS questions;

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  author_id INTEGER NOT NULL,

  FOREIGN KEY (author_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS question_follows;

CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  follower_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (follower_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

DROP TABLE IF EXISTS replies;

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  parent_reply_id INTEGER,
  user_id INTEGER NOT NULL,
  reply_body TEXT NOT NULL,

  FOREIGN KEY (question_id) REFERENCES questions(id)
  FOREIGN KEY (user_id) REFERENCES users(id)
  FOREIGN KEY (parent_reply_id) REFERENCES replies(id)
);

DROP TABLE IF EXISTS question_likes;

CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  liker_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (liker_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

INSERT INTO
  users (fname, lname)
VALUES
  ('Khai', 'Bui'),
  ('Lisa', 'Togler'),
  ('Bruce', 'Wayne'),
  ('David', 'Hasselhoff'),
  ('Tony', 'Stark');

INSERT INTO
  questions (title, body, author_id)
VALUES
  ('Lunch?', 'What did you get for lunch?', (
    SELECT id FROM users WHERE users.fname = 'Lisa' AND users.lname = 'Togler'
  )),
  ('Soylent?', 'Can I survive a year with only Soylent?', (
    SELECT id FROM users WHERE fname = 'Khai' AND lname = 'Bui'
  ));
