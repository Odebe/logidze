CREATE TRIGGER logidze_before_update_on_<%= full_table_name %>
BEFORE UPDATE ON <%= full_table_name %> FOR EACH ROW
BEGIN
    DECLARE new_j json;
    DECLARE old_j json;
    DECLARE columns_j json;
    DECLARE log_data json;

    IF COALESCE(@logidze.disabled, '') <> 'on' THEN
        SET new_j = <%= new_json %>;
        SET old_j = <%= old_json %>;
        SET columns_j = <%= columns_json %>;

        SET log_data = logidze_logger(<%= logidze_logger_parameters('UPDATE') %>);

        IF log_data IS NOT NULL THEN
            SET NEW.log_data = log_data;
        END IF;
    END IF;
END;