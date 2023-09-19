CREATE PROCEDURE logidze_version(IN v bigint, IN data JSON, IN ts timestamp, OUT result JSON)
BEGIN
    -- version: 1
    SET result = JSON_OBJECT(
        'ts',
        UNIX_TIMESTAMP(ts),
        'v',
        v,
        'c',
        -- workaround because JSON_REMOVE returns removed value
        JSON_REPLACE(data, '$.log_data', null)
        );
    -- TODO: check meta
    select result;
END;
