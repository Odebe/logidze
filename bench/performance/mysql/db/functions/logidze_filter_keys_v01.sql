CREATE FUNCTION logidze_filter_keys(item json, columns json) RETURNS json NO SQL
BEGIN
    -- version: 1
    DECLARE i integer DEFAULT 0;
    DECLARE current_key text;
    DECLARE current_key_path text;
    DECLARE result json DEFAULT JSON_OBJECT();

    WHILE i < JSON_LENGTH(columns) DO
        SET current_key = JSON_EXTRACT(columns, CONCAT('$[', i, ']'));
        SET current_key_path = CONCAT('$.', current_key);

        SET result = JSON_INSERT(result, current_key_path, JSON_EXTRACT(item, current_key_path));

        SET i = i + 1;
    END WHILE;

    RETURN result;
END;