DELIMITER $$

CREATE PROCEDURE logidze_version(
    IN v bigint,
    IN data JSON,
-- тут будет фигня с таймзонами
    IN ts timestamp,
    OUT result JSON
)
-- version: 1
BEGIN
    -- TODO
END$$

DELIMITER ;
