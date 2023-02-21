CREATE TABLE products(
  id         bigserial PRIMARY KEY,
  created_at timestamp,
  category   text,
  ean        text,
  price      float,
  quantity   int default(5000),
  rating     float,
  title      text,
  vendor     text
);
