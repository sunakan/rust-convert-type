DROP TABLE IF EXISTS users;
CREATE TABLE users (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);


DROP TABLE IF EXISTS microposts;
CREATE TABLE microposts (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    content VARCHAR(255) NOT NULL,
    user_id BIGINT NOT NULL REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE FUNCTION set_update_time() RETURNS TRIGGER AS '
  begin
    new.updated_at = ''now'';
    return new;
  end;
' LANGUAGE plpgsql;


CREATE TRIGGER update_tri BEFORE UPDATE ON users FOR EACH ROW EXECUTE PROCEDURE set_update_time();
