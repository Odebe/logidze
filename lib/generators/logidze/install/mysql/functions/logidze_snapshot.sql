DELIMITER $$
DROP PROCEDURE IF EXISTS logidze_snapshot$$
CREATE PROCEDURE logidze_snapshot(IN item JSON, IN ts_column text, IN columns text, IN include_columns boolean, OUT result JSON)
BEGIN
-- version: 1
END$$
DELIMITER ;
