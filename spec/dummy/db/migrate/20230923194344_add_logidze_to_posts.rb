class AddLogidzeToPosts < ActiveRecord::Migration[6.0]
  def change
    add_column :posts, :log_data, :json

    reversible do |dir|
      dir.up do
        execute <<~SQL
          CREATE TRIGGER logidze_before_update_on_posts
          BEFORE UPDATE ON posts FOR EACH ROW
          BEGIN
              DECLARE new_j json;
              DECLARE old_j json;
              DECLARE columns_j json;
              DECLARE log_data json;

              IF COALESCE(@logidze.disabled, '') <> 'on' THEN
                  SET new_j = JSON_OBJECT('title', NEW.title, 'log_data', NEW.log_data);
                  SET old_j = JSON_OBJECT('title', OLD.title, 'log_data', OLD.log_data);
                  SET columns_j = JSON_ARRAY('title', 'log_data');

                  SET log_data = logidze_logger(old_j, new_j, JSON_ARRAY('title', 'log_data'), 'UPDATE', NULL);

                  IF log_data IS NOT NULL THEN
                      SET NEW.log_data = log_data;
                  END IF;
              END IF;
          END;
        SQL
        execute <<~SQL
          CREATE TRIGGER logidze_before_insert_on_posts
          BEFORE INSERT ON posts FOR EACH ROW
          BEGIN
              DECLARE new_j json;
              DECLARE old_j json;
              DECLARE columns_j json;
              DECLARE log_data json;

              IF COALESCE(@logidze.disabled, '') <> 'on' THEN
                  SET new_j = JSON_OBJECT('title', NEW.title, 'log_data', NEW.log_data);
                  SET old_j = '{}';
                  SET columns_j = JSON_ARRAY('title', 'log_data');

                  SET log_data = logidze_logger(old_j, new_j, JSON_ARRAY('title', 'log_data'), 'INSERT', NULL);

                  IF log_data IS NOT NULL THEN
                      SET NEW.log_data = log_data;
                  END IF;
              END IF;
          END;

        SQL
      end

      dir.down do
        execute <<~SQL
          DROP TRIGGER IF EXISTS logidze_before_insert_on_posts;
        SQL
        execute <<~SQL
          DROP TRIGGER IF EXISTS logidze_before_update_on_posts;
        SQL
      end
    end
  end
end
