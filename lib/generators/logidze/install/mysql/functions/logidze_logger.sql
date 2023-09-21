CREATE FUNCTION logidze_logger(old json, columns json, trigger_type text, new json) RETURNS json NO SQL
BEGIN
    -- version: 1
    DECLARE log_data json;
    DECLARE i integer DEFAULT 0;
    DECLARE columns_count integer DEFAULT JSON_LENGTH(columns);
    DECLARE changes json;
    DECLARE version json;
    DECLARE new_v integer;
    DECLARE ts timestamp;
    DECLARE current_key text;
    DECLARE current_key_path text;

--  TODO: add exception handler
    IF JSON_VALUE(new, '$.log_data') IS NULL OR JSON_LENGTH(JSON_EXTRACT(new, '$.log_data')) = 0 THEN
        SET log_data = logidze_snapshot(new, columns);
    ELSE
        SET log_data = JSON_VALUE(new, '$.log_data');

        IF trigger_type = 'UPDATE' AND (old = new) THEN
            RETURN null; -- pass
        END IF;

--  TODO: set ts based in ts_column
        SET ts = LOCALTIMESTAMP;
        SET changes = JSON_REMOVE(new, '$.log_data');

-- TODO: if JSON_VALUE(log_data, '$.v') < JSON_VALUE(log_data, '$.h[last].v')
-- TODO:    remove versions with number greater or equal than JSON_VALUE(log_data, '$.v')
        WHILE i < columns_count DO
            SET current_key = JSON_EXTRACT(columns, CONCAT('$[', i, ']'));
            SET current_key_path = CONCAT('$.', current_key);

            IF JSON_EXTRACT(changes, current_key_path) = JSON_EXTRACT(old, current_key_path) THEN
                SET changes = JSON_REMOVE(changes, current_key_path);
            END IF;

            SET i = i + 1;
        END WHILE;

        IF JSON_LENGTH(changes) = 0 THEN
            RETURN null; -- pass
        END IF;

        SET new_v = JSON_VALUE(log_data, '$.h[last].v' RETURNING unsigned) + 1;
        SET version = logidze_version(new_v, changes, ts);

--  TODO: limit history
        SET log_data = JSON_ARRAY_APPEND(log_data, '$.h', version);
        SET log_data = JSON_SET(log_data, '$.v', new_v);
    END IF;

    RETURN log_data; -- result
END;