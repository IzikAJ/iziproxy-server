-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
CREATE TABLE auth_tokens (
  id SERIAL UNIQUE,
  user_id BIGINT NOT NULL,
  token VARCHAR(100) NOT NULL,
  remote_ip INET,
  expired_at TIMESTAMP,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);
CREATE UNIQUE INDEX uniq_auth_tokens ON auth_tokens (token);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP INDEX uniq_auth_tokens;
DROP TABLE auth_tokens;
