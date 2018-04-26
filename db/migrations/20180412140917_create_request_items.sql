-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
CREATE SEQUENCE request_items_id_seq;
CREATE TABLE request_items (
  id BIGINT PRIMARY KEY NOT NULL DEFAULT nextval('request_items_id_seq'),
  uuid UUID NOT NULL,
  client_uuid UUID NOT NULL,
  connection_id BIGINT,
  remote_ip VARCHAR(200),
  method VARCHAR(30),

  path VARCHAR(512),
  query VARCHAR(1024),
  status_code INTEGER,

  created_at TIMESTAMP,
  updated_at TIMESTAMP
);
ALTER SEQUENCE request_items_id_seq OWNED BY request_items.id;
CREATE INDEX request_items_connection_id ON request_items (connection_id);
CREATE INDEX request_items_client_uuid ON request_items (client_uuid);
CREATE INDEX request_items_uuid ON request_items (uuid);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP INDEX request_items_connection_id;
DROP INDEX request_items_client_uuid;
DROP INDEX request_items_uuid;
DROP TABLE request_items;
