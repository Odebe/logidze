CREATE FUNCTION logidze_compact_history(log_data json, cutoff integer) RETURNS json NO SQL
BEGIN
    -- version: 1
    DECLARE new_history_item json;

    IF cutoff IS NULL THEN
        SET cutoff = 1;
    END IF;

    iteration: LOOP
      SET new_history_item = JSON_OBJECT(
          'ts', JSON_EXTRACT(log_data, '$.h[1].ts'),
          'v',  JSON_EXTRACT(log_data, '$.h[1].v'),
          'c',  JSON_MERGE_PATCH(JSON_EXTRACT(log_data, '$.h[0].c'), JSON_EXTRACT(log_data, '$.h[1].c'))
      );

      IF JSON_CONTAINS_PATH(log_data, 'one', '$.h[1].m') THEN
          SET new_history_item = JSON_INSERT(new_history_item, '$.m', JSON_EXTRACT(log_data, '$.h[1].m'));
      END IF;

      SET new_history_item = JSON_REPLACE(log_data, '$.h[1]', new_history_item);
      SET log_data = JSON_REMOVE(new_history_item, '$.h[0]');

      SET cutoff = cutoff - 1;

      IF cutoff <= 0 THEN
          LEAVE iteration;
      END IF;
    END LOOP iteration;

    RETURN log_data;
END;