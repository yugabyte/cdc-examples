CREATE TABLE users(
  id         bigserial PRIMARY KEY,
  created_at timestamp,
  name       text,
  email      text,
  birth_date text,
  country    text,
  password   text,
  source     text
);
