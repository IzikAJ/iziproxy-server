-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
CREATE TABLE sessions (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGSERIAL,
  token VARCHAR(256) NOT NULL,
  remote_ip INET,
  expired_at TIMESTAMP,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);
CREATE UNIQUE INDEX uniq_session_tokens ON sessions (token);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP INDEX uniq_session_tokens;
DROP TABLE sessions;
