DROP TABLE if exists users;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  f_name VARCHAR(50) NOT NULL,
  l_name VARCHAR(50) NOT NULL
);

DROP TABLE if exists questions;

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title VARCHAR(100) NOT NULL,
  body TEXT NOT NULL,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id)
);

DROP TABLE if exists question_follows;

CREATE TABLE question_follows (
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  PRIMARY KEY (user_id, question_id)
  FOREIGN KEY (user_id) REFERENCES users(id)
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

DROP TABLE if exists replies;

CREATE TABLE replies(
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  parent_id INTEGER,
  user_id INTEGER NOT NULL,
  body TEXT NOT NULL,

  FOREIGN KEY (parent_id) REFERENCES replies(id)
  FOREIGN KEY (question_id) REFERENCES questions(id)
  FOREIGN KEY (user_id) REFERENCES users(id)
);

DROP TABLE if exists question_likes;

CREATE TABLE question_likes(
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  PRIMARY KEY (user_id, question_id)
  FOREIGN KEY (user_id) REFERENCES users(id)
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

INSERT INTO users (f_name, l_name) VALUES ('John', 'Doe');
INSERT INTO users (f_name, l_name) VALUES ('Jane', 'Abernathy');
INSERT INTO users (f_name, l_name) VALUES ('Quentin', 'Quinto');

INSERT INTO
  questions (title, body, user_id)
VALUES
  ('SQL Foreign Key Enforcement', 'This stuff is broken.', (
    SELECT
      id
    FROM
      users
    WHERE
      f_name = 'Quentin' AND l_name = 'Quinto'
  ));
INSERT INTO questions (title, body, user_id) VALUES ('Foo?', 'Bar?', 1);

INSERT INTO
  question_follows (user_id, question_id)
VALUES
  (2,1);

INSERT INTO
  question_follows (user_id, question_id)
VALUES
  (1,1);

INSERT INTO
  question_likes (user_id, question_id)
VALUES
  (1,2);

INSERT INTO
  replies (question_id, parent_id, user_id, body)
VALUES
  (1, NULL, 2, 'I know, rite?');

INSERT INTO
  replies (question_id, parent_id, user_id, body)
VALUES
  (1, 1, 1, 'What''s wrong with you?');
