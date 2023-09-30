# frozen_string_literal: true

class AddLogidzeToLogidzeUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :logidze_users, :log_data, :json

    reversible do |dir|
      dir.up do
        create_trigger :logidze_before_insert_on_logidze_users, on: :logidze_users
        create_trigger :logidze_before_update_on_logidze_users, on: :logidze_users
      end

      dir.down do
        execute <<~SQL
          DROP TRIGGER IF EXISTS `logidze_before_insert_on_logidze_users`;
        SQL

        execute <<~SQL
          DROP TRIGGER IF EXISTS `logidze_before_update_on_logidze_users`;
        SQL
      end
    end
  end
end
