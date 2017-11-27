-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
CREATE TABLE users (
  id SERIAL UNIQUE,
  email VARCHAR(150) NOT NULL UNIQUE,
  encrypted_password VARCHAR(500) NOT NULL,
  name VARCHAR(100),
  last_login_at TIMESTAMP,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);
CREATE UNIQUE INDEX uniq_user_emails ON users (LOWER(email));
-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP INDEX uniq_user_emails;
DROP TABLE users;
