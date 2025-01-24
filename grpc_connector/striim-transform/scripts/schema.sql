CREATE TABLE users(
  id         bigserial PRIMARY KEY,
  created_at timestamp,
  name       text,
  email      text,
  address    text,
  city       text,
  state      text,
  zip        text,
  birth_date text,
  latitude   float,
  longitude  float,
  password   text,
  source     text
);
