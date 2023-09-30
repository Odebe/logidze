CREATE TRIGGER `logidze_before_insert_on_logidze_users`
BEFORE INSERT ON `logidze_users` FOR EACH ROW
BEGIN
    DECLARE new_j json;
    DECLARE old_j json;
    DECLARE columns_j json;
    DECLARE log_data json;

    IF COALESCE(@logidze.disabled, '') <> 'on' THEN
        SET new_j = JSON_OBJECT('email', NEW.email, 'position', NEW.position, 'name', NEW.name, 'bio', NEW.bio, 'age', NEW.age, 'dump', NEW.dump, 'data', NEW.data);
        SET old_j = '{}';
        SET columns_j = JSON_ARRAY('email', 'position', 'name', 'bio', 'age', 'dump', 'data');

        SET log_data = logidze_logger(old_j, new_j, JSON_ARRAY('name', 'age', 'active', 'log_data'), 'INSERT', NULL);

        IF log_data IS NOT NULL THEN
            SET NEW.log_data = log_data;
        END IF;
    END IF;
END;
