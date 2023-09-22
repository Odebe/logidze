CREATE FUNCTION logidze_version(v bigint, data JSON, ts text) RETURNS json NO SQL
BEGIN
    -- version: 1
    DECLARE result json;

    SET result = JSON_OBJECT(
            'ts', UNIX_TIMESTAMP(ts),
            'v', v,
            'c', JSON_REMOVE(data, '$.log_data')
        );

    IF COALESCE(@logidze.meta, '') <> '' THEN
        SET result = JSON_INSERT(result, '$.m', JSON_UNQUOTE(@logidze.meta));
    END IF;

    RETURN result;
END;