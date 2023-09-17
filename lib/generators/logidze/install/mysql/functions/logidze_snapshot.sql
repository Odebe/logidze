DELIMITER $$

CREATE PROCEDURE logidze_snapshot(
    IN item JSON,
    IN ts_column text,
    IN columns text,
    IN include_columns boolean,
    OUT result JSON
)
-- version: 1
BEGIN
    -- TODO
END$$

DELIMITER ;
