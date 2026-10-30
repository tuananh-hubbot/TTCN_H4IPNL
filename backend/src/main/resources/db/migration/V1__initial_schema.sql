-- Initial demonstration table. Business schema will be added in later migrations.
CREATE TABLE app_metadata (
    id BIGINT NOT NULL AUTO_INCREMENT,
    meta_key VARCHAR(100) NOT NULL,
    meta_value VARCHAR(500) NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_app_metadata_key (meta_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO app_metadata (meta_key, meta_value) VALUES ('schema_version', '1');
