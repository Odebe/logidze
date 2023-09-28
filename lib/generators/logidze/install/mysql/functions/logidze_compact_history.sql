CREATE FUNCTION logidze_compact_history(log_data json, cutoff integer) RETURNS json NO SQL
BEGIN
    -- version: 1
    DECLARE new_history_item json;
    DECLARE merged json;
    DECLARE newer_content json;
    DECLARE merge_keys json;
    DECLARE current_key text;
    DECLARE merge_path text;
    DECLARE keys_count integer;
    DECLARE i integer;

    IF cutoff IS NULL THEN
        SET cutoff = 1;
    END IF;

    iteration: LOOP
      SET merged = JSON_EXTRACT(log_data, '$.h[0].c');
      SET newer_content = JSON_EXTRACT(log_data, '$.h[1].c');

-- Implementing "merged::jsonb || null" behaviour like in postgresql
      IF NULLIF(JSON_UNQUOTE(newer_content), 'null') IS NULL THEN
          SET merged = null;
      ELSE
          SET i = 0;
          SET merge_keys = JSON_KEYS(newer_content);
          SET keys_count = CAST(JSON_LENGTH(newer_content) AS unsigned);

          merging: WHILE i < keys_count DO
            SET current_key = JSON_EXTRACT(merge_keys, CONCAT('$[', i, ']'));
            SET merge_path = CONCAT('$.', current_key);
            SET merged = JSON_SET(merged, merge_path, JSON_EXTRACT(newer_content, merge_path));

            SET i = i + 1;
          END WHILE merging;
      END IF;

      SET new_history_item = JSON_OBJECT(
          'ts', JSON_EXTRACT(log_data, '$.h[1].ts'),
          'v',  JSON_EXTRACT(log_data, '$.h[1].v'),
          'c',  merged
      );

      IF JSON_CONTAINS_PATH(log_data, 'one', '$.h[1].m') THEN
          SET new_history_item = JSON_INSERT(new_history_item, '$.m', JSON_EXTRACT(log_data, '$.h[1].m'));
      END IF;

      SET new_history_item = JSON_SET(log_data, '$.h[1]', new_history_item);
      SET log_data = JSON_REMOVE(new_history_item, '$.h[0]');

      SET cutoff = cutoff - 1;

      IF cutoff <= 0 THEN
          LEAVE iteration;
      END IF;
    END LOOP iteration;

    RETURN log_data;
END;