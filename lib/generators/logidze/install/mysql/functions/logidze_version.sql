DELIMITER $$
DROP PROCEDURE IF EXISTS logidze_version$$
CREATE PROCEDURE logidze_version(IN v bigint, IN data JSON, IN ts timestamp, OUT result JSON)
BEGIN
-- version: 1
END$$
DELIMITER ;
