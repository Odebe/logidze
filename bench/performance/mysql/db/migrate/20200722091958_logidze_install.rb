# frozen_string_literal: true

class LogidzeInstall < ActiveRecord::Migration[6.0]
  def change
    reversible do |dir|
      dir.up do
        create_function :logidze_compact_history, version: 1
      end

      dir.down do
        execute "DROP FUNCTION IF EXISTS logidze_compact_history"
      end
    end

    reversible do |dir|
      dir.up do
        create_function :logidze_filter_keys, version: 1
      end

      dir.down do
        execute "DROP FUNCTION IF EXISTS logidze_filter_keys"
      end
    end

    reversible do |dir|
      dir.up do
        create_function :logidze_logger, version: 1
      end

      dir.down do
        execute "DROP FUNCTION IF EXISTS logidze_logger"
      end
    end

    reversible do |dir|
      dir.up do
        create_function :logidze_snapshot, version: 1
      end

      dir.down do
        execute "DROP FUNCTION IF EXISTS logidze_snapshot"
      end
    end

    reversible do |dir|
      dir.up do
        create_function :logidze_version, version: 1
      end

      dir.down do
        execute "DROP FUNCTION IF EXISTS logidze_version"
      end
    end
  end
end
