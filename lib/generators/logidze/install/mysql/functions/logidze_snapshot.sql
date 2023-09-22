CREATE FUNCTION logidze_snapshot(item JSON, columns json) RETURNS json NO SQL
BEGIN
    -- version: 1
    DECLARE result json;
    DECLARE version_content json;
    DECLARE i integer DEFAULT 0;
    DECLARE columns_count integer DEFAULT JSON_LENGTH(columns);
    DECLARE current_key text;
    DECLARE current_key_path text;

    SET version_content = logidze_filter_keys(item, columns);

    WHILE i < columns_count DO
        SET current_key = JSON_EXTRACT(columns, CONCAT('$[', i, ']'));
        SET current_key_path = CONCAT('$.', current_key);

        IF JSON_TYPE(version_content) = 'OBJECT' THEN
            SET version_content = JSON_REPLACE(
                version_content,
                current_key_path,
                JSON_UNQUOTE(JSON_EXTRACT(version_content, current_key_path))
            );
        END IF;

        SET i = i + 1;
    END WHILE;

    SET result = JSON_OBJECT(
        'v', 1,
        'h', JSON_ARRAY(logidze_version(1, version_content, LOCALTIMESTAMP))
    );

    RETURN result;
END;