CREATE FUNCTION logidze_logger(old json, new json, columns json, trigger_type text, history_limit integer) RETURNS json NO SQL
BEGIN
    -- version: 1
    DECLARE log_data json;
    DECLARE i integer DEFAULT 0;
    DECLARE history_size integer;
    DECLARE columns_count integer DEFAULT JSON_LENGTH(columns);
    DECLARE changes json;
    DECLARE version json;
    DECLARE new_v integer;
    DECLARE ts timestamp;
    DECLARE current_key text;
    DECLARE current_key_path text;
    DECLARE full_snapshot boolean;
    DECLARE current_version integer;

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
        SET full_snapshot = COALESCE(@logidze.full_snapshot, '') = 'on' OR trigger_type = 'INSERT';
        SET current_version = JSON_VALUE(log_data, '$.v');

        IF current_version < JSON_VALUE(log_data, '$.h[last].v') THEN
            removing_newer_versions: LOOP
                IF current_version < JSON_VALUE(log_data, '$.h[last].v') THEN
                    SET log_data = JSON_REMOVE(log_data, '$.h[last]');
                ELSE
                    LEAVE removing_newer_versions;
                END IF;
            END LOOP removing_newer_versions;
        END IF;

-- TODO: if JSON_VALUE(log_data, '$.v') < JSON_VALUE(log_data, '$.h[last].v')
-- TODO:    remove versions with number greater or equal than JSON_VALUE(log_data, '$.v')
        IF full_snapshot <> TRUE THEN
            WHILE i < columns_count DO
                SET current_key = JSON_EXTRACT(columns, CONCAT('$[', i, ']'));
                SET current_key_path = CONCAT('$.', current_key);

                IF JSON_EXTRACT(changes, current_key_path) = JSON_EXTRACT(old, current_key_path) THEN
                    SET changes = JSON_REMOVE(changes, current_key_path);
                END IF;

                SET i = i + 1;
            END WHILE;
        END IF;

        IF JSON_LENGTH(changes) = 0 THEN
            RETURN null; -- pass
        END IF;

        SET new_v = JSON_VALUE(log_data, '$.h[last].v' RETURNING unsigned) + 1;
        SET version = logidze_version(new_v, changes, ts);
        SET log_data = JSON_ARRAY_APPEND(log_data, '$.h', version);
        SET log_data = JSON_SET(log_data, '$.v', new_v);
        SET history_size = JSON_LENGTH(log_data, '$.h');

        IF history_limit IS NOT NULL AND history_limit <= history_size THEN
            SET log_data = logidze_compact_history(log_data, history_size - history_limit);
        END IF;
    END IF;

    RETURN log_data; -- result
END;