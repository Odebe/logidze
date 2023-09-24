CREATE FUNCTION logidze_logger(old json, new json, columns json, trigger_type text, history_limit integer) RETURNS json NO SQL
BEGIN
    -- version: 1
    DECLARE log_data json;
    DECLARE i integer DEFAULT 0;
    DECLARE history_size integer;
    DECLARE columns_count integer DEFAULT JSON_LENGTH(columns);
    DECLARE changes json;
    DECLARE version json;
    DECLARE new_v integer unsigned;
    DECLARE ts timestamp;
    DECLARE current_key text;
    DECLARE current_key_path text;
    DECLARE full_snapshot boolean;
    DECLARE current_version integer unsigned;
    DECLARE last_history_elem_path text;

--  TODO: add exception handler
    IF NULLIF(JSON_UNQUOTE(JSON_EXTRACT(new, '$.log_data')), 'null') IS NULL OR
        JSON_EXTRACT(new, '$.log_data') = JSON_OBJECT()
    THEN
        SET log_data = logidze_snapshot(new, columns);
    ELSE
        SET log_data = CAST(JSON_EXTRACT(new, '$.log_data') AS json);

        IF trigger_type = 'UPDATE' AND (old = new) THEN
            RETURN null; -- pass
        END IF;

--  TODO: set ts based in ts_column
        SET ts = LOCALTIMESTAMP;

        SET changes = JSON_REMOVE(new, '$.log_data');
        SET full_snapshot = COALESCE(@logidze.full_snapshot, '') = 'on' OR trigger_type = 'INSERT';
        SET current_version = CAST(JSON_EXTRACT(log_data, '$.v') AS unsigned);
        SET last_history_elem_path = CONCAT('$.h[', JSON_LENGTH(log_data, '$.h') - 1, ']');

        IF current_version < CAST(JSON_EXTRACT(log_data, CONCAT(last_history_elem_path, '.v')) AS unsigned) THEN
            removing_newer_versions: LOOP
                SET last_history_elem_path = CONCAT('$.h[', JSON_LENGTH(log_data, '$.h') - 1, ']');

                IF current_version < CAST(JSON_EXTRACT(log_data, CONCAT(last_history_elem_path, '.v')) AS unsigned) THEN
                    SET log_data = JSON_REMOVE(log_data, last_history_elem_path);
                ELSE
                    LEAVE removing_newer_versions;
                END IF;
            END LOOP removing_newer_versions;
        END IF;

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

        SET new_v = CAST(JSON_EXTRACT(log_data, '$.h[last].v') AS unsigned) + 1;
        SET version = logidze_version(new_v, changes, ts);
        SET log_data = JSON_ARRAY_APPEND(log_data, '$.h', version);
        SET log_data = JSON_SET(log_data, '$.v', new_v);
        SET history_size = JSON_LENGTH(log_data, '$.h');

        IF history_limit IS NOT NULL AND history_limit < history_size THEN
            SET log_data = logidze_compact_history(log_data, history_size - history_limit);
        END IF;
    END IF;

    RETURN log_data; -- result
END;