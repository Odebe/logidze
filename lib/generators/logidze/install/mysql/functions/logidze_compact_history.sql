CREATE PROCEDURE logidze_compact_history(IN log_data JSON, IN cutoff integer, OUT result JSON)
BEGIN
-- version: 1
    DECLARE cutoff_value INT DEFAULT 1;

    SET cutoff_value = IFNULL(cutoff, 1);
END;
