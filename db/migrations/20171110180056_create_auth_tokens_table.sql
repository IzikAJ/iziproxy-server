-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
CREATE SEQUENCE auth_tokens_id_seq;
CREATE TABLE auth_tokens (
  id BIGINT PRIMARY KEY NOT NULL DEFAULT nextval('auth_tokens_id_seq'),
  user_id BIGINT NOT NULL,
  token VARCHAR(100) NOT NULL,
  remote_ip INET,
  expired_at TIMESTAMP,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);
ALTER SEQUENCE auth_tokens_id_seq OWNED BY auth_tokens.id;
CREATE UNIQUE INDEX uniq_auth_tokens ON auth_tokens (token);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP INDEX uniq_auth_tokens;
DROP TABLE auth_tokens;
