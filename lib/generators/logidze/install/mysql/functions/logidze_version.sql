CREATE FUNCTION logidze_version(v bigint, data JSON, ts text) RETURNS json NO SQL
BEGIN
    -- version: 1
    DECLARE result json;

    SET result = JSON_OBJECT(
            'ts', UNIX_TIMESTAMP(ts) * 1000,
            'v', v,
            'c', JSON_REMOVE(data, '$.log_data')
        );

    IF COALESCE(@logidze.meta, '') <> '' THEN
        SET result = JSON_INSERT(result, '$.m', CAST(JSON_UNQUOTE(@logidze.meta) AS json));
    END IF;

    RETURN result;
END;