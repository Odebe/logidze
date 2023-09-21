CREATE FUNCTION logidze_snapshot(item JSON, columns json) RETURNS json NO SQL
BEGIN
    -- version: 1
    DECLARE result json;
    DECLARE version_content json;

    SET version_content = logidze_filter_keys(item, columns);
    SET result = JSON_OBJECT(
            'v', 1,
            'h', JSON_ARRAY(logidze_version(1, version_content, LOCALTIMESTAMP))
        );

    RETURN result;
END;