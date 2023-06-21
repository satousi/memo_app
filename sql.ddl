--DBの作成

CREATE DATABASE mydb;

--テーブルの作成

CREATE TABLE memos (
  id SERIAL PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  content TEXT
);