-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
CREATE TABLE users (
  id SERIAL UNIQUE,
  email VARCHAR(150) NOT NULL UNIQUE,
  encrypted_password VARCHAR(500) NOT NULL,
  reset_password_token VARCHAR(100) UNIQUE,
  name VARCHAR(100),
  last_login_at TIMESTAMP,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);
CREATE UNIQUE INDEX uniq_user_emails ON users (LOWER(email));
CREATE UNIQUE INDEX user_reset_password_token ON users (reset_password_token);
-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP INDEX uniq_user_emails;
DROP INDEX user_reset_password_token;
DROP TABLE users;
