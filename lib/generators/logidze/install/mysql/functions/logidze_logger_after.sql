DELIMITER $$
CREATE PROCEDURE logidze_logger_after()
-- version: 1
    BEGIN
    <%= generate_logidze_logger_after %>
    END$$
DELIMITER ;
