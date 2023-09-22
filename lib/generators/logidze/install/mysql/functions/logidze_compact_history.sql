CREATE FUNCTION logidze_compact_history(log_data json, cutoff integer) RETURNS json NO SQL
BEGIN
    -- version: 1
    DECLARE cutoff integer default 1;
    DECLARE new_version json;
    DECLARE result json;

    iteration: LOOP
      SET new_version = JSON_OBJECT(
          'ts', JSON_EXTRACT(log_data, '$.h[1].ts'),
          'v',  JSON_EXTRACT(log_data, '$.h[1].v'),
          'c',  JSON_MERGE_PATCH(JSON_EXTRACT(log_data, '$.h[0].c'), JSON_EXTRACT(log_data, '$.h[1].c'))
      );

      IF JSON_CONTAINS_PATH(log_data, 'one', '$.h[1].m') THEN
          SET new_version = JSON_INSERT(new_version, '$.m', JSON_EXTRACT(log_data, '$.h[1].m'));
      END IF;

      SET new_version = JSON_REPLACE(log_data, '$.h[1]', new_version);
      SET result = JSON_REMOVE(new_version, '$.h[0]');

      SET cutoff = cutoff - 1;

      IF cutoff <= 0 THEN
          LEAVE iteration;
      END IF;
    END LOOP iteration;

    RETURN result;
END;