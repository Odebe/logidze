CREATE TRIGGER logidze_before_insert_on_<%= full_table_name %>
BEFORE INSERT ON <%= full_table_name %> FOR EACH ROW
BEGIN
    DECLARE new_j json;
    DECLARE columns_j json;
    DECLARE log_data json;

    SET new_j = <%= new_json %>;
    SET columns_j = <%= columns_json %>;

    SET log_data = logidze_logger('{}', columns_j,'INSERT', new_j);

    IF log_data IS NOT NULL THEN
        SET NEW.log_data = log_data;
    END IF;
END;
