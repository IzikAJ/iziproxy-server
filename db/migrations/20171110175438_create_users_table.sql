-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
CREATE SEQUENCE users_id_seq;
CREATE TABLE users (
  id BIGINT PRIMARY KEY NOT NULL DEFAULT nextval('users_id_seq'),
  email VARCHAR(150) NOT NULL UNIQUE,
  encrypted_password VARCHAR(500) NOT NULL,
  reset_password_token VARCHAR(100) UNIQUE,
  name VARCHAR(100),
  log_requests BOOLEAN DEFAULT FALSE,
  last_login_at TIMESTAMP,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);
ALTER SEQUENCE users_id_seq OWNED BY users.id;
CREATE UNIQUE INDEX uniq_user_emails ON users (LOWER(email));
CREATE UNIQUE INDEX user_reset_password_token ON users (reset_password_token);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP INDEX uniq_user_emails;
DROP INDEX user_reset_password_token;
DROP TABLE users;
