-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
CREATE SEQUENCE sessions_id_seq;
CREATE TABLE sessions (
  id BIGINT PRIMARY KEY NOT NULL DEFAULT nextval('sessions_id_seq'),
  user_id BIGINT,
  token VARCHAR(256) NOT NULL,
  remote_ip VARCHAR(200),
  expired_at TIMESTAMP,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);
ALTER SEQUENCE sessions_id_seq OWNED BY sessions.id;
CREATE UNIQUE INDEX uniq_session_tokens ON sessions (token);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP INDEX uniq_session_tokens;
DROP TABLE sessions;
