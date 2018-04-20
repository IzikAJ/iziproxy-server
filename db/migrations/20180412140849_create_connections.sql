-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
CREATE SEQUENCE connections_id_seq;
CREATE TABLE connections (
  id BIGINT PRIMARY KEY NOT NULL DEFAULT nextval('connections_id_seq'),
  client_uuid UUID NOT NULL,
  user_id BIGINT,
  remote_ip VARCHAR(200),
  subdomain VARCHAR(200),
  packets_count INTEGER DEFAULT 0,
  errors_count INTEGER DEFAULT 0,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);
ALTER SEQUENCE connections_id_seq OWNED BY connections.id;
CREATE INDEX connections_client_uuid ON connections (client_uuid);
CREATE INDEX connections_user_id ON connections (user_id);
CREATE INDEX connections_remote_ip ON connections (remote_ip);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP INDEX connections_client_uuid;
DROP INDEX connections_user_id;
DROP INDEX connections_remote_ip;
DROP TABLE connections;
