-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
CREATE TABLE request_items (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGSERIAL,
  uuid UUID NOT NULL,
  client_uuid UUID NOT NULL,
  request TEXT,
  status_code INTEGER,
  response TEXT,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);
CREATE INDEX request_items_client_uuid ON request_items (client_uuid);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP INDEX request_items_client_uuid;
DROP TABLE request_items;
