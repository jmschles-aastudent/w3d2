CREATE TABLE users (
	id INTEGER PRIMARY KEY,
	fname VARCHAR(255) NOT NULL,
	lname VARCHAR(255) NOT NULL
);

CREATE TABLE questions (
	id INTEGER PRIMARY KEY,
	title VARCHAR(255) NOT NULL,
	body VARCHAR(255) NOT NULL,
	author_id INTEGER NOT NULL,

	FOREIGN KEY (author_id) REFERENCES users(id)
);

CREATE TABLE question_followers (
	id INTEGER PRIMARY KEY,
	question_id INTEGER NOT NULL,
	follower_id INTEGER NOT NULL,

	FOREIGN KEY (question_id) REFERENCES questions(id),
	FOREIGN KEY (follower_id) REFERENCES users(id)
);

CREATE TABLE replies (
	id INTEGER PRIMARY KEY,
	body VARCHAR(255) NOT NULL,
	author_id INTEGER NOT NULL,
	question_id INTEGER NOT NULL,
	parent_reply_id INTEGER,

	FOREIGN KEY (author_id) REFERENCES users(id),
	FOREIGN KEY (question_id) REFERENCES questions(id),
	FOREIGN KEY (parent_reply_id) REFERENCES replies(id)
);

CREATE TABLE question_likes (
	id INTEGER PRIMARY KEY,
	user_id INTEGER NOT NULL,
	question_id INTEGER NOT NULL,

	FOREIGN KEY (user_id) REFERENCES users(id),
	FOREIGN KEY (question_id) REFERENCES questions(id)
);

CREATE TABLE tags (
	id INTEGER PRIMARY KEY,
	name VARCHAR(255)
);

CREATE TABLE question_tags (
	id INTEGER PRIMARY KEY,
	question_id INTEGER NOT NULL,
	tag_id INTEGER NOT NULL,

	FOREIGN KEY (question_id) REFERENCES questions(id),
	FOREIGN KEY (tag_id) REFERENCES tags(id)
);

INSERT INTO users ('fname', 'lname')
VALUES ('Brian', 'Mason'), ('Jamie', 'Schlessinger'), ('Ned', 'Flanders');

INSERT INTO questions ('title', 'body', 'author_id')
VALUES ('What is SQL?', 'Seriously, what is it?', 1),
			 ('Where are we?', 'What is this place?', 2),
		 	 ('Why do we need another question?', 'So that we can test a new feature?', 1);

INSERT INTO question_followers ('question_id', 'follower_id')
VALUES (2, 1), (1, 2), (2, 3);

INSERT INTO replies ('body', 'author_id', 'question_id', 'parent_reply_id')
VALUES ("I think we're in San Francisco", 1, 2, NULL),
			 ("Yeah that sounds right.", 2, 2, 1),
		   ("YES", 1, 2, 2);

INSERT INTO question_likes ('user_id', 'question_id')
VALUES (2, 2), (1, 1), (3, 1);

INSERT INTO tags ('name')
VALUES ('html'), ('css'), ('javascript'), ('ruby'), ('sql');

INSERT INTO question_tags ('question_id', 'tag_id')
VALUES (1, 5), (2, 4), (3, 4);