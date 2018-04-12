-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
CREATE SEQUENCE connection_logs_id_seq;
CREATE TABLE connection_logs (
  id BIGINT PRIMARY KEY NOT NULL DEFAULT nextval('connection_logs_id_seq'),
  connection_id BIGINT NOT NULL,
  message VARCHAR(250),
  level INTEGER,
  created_at TIMESTAMP
);
ALTER SEQUENCE connection_logs_id_seq OWNED BY connection_logs.id;
CREATE INDEX connection_logs_connection_id ON connection_logs (connection_id);
CREATE INDEX connection_logs_level ON connection_logs (level);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP INDEX connection_logs_connection_id;
DROP INDEX connection_logs_level;
DROP TABLE connection_logs;
