# frozen_string_literal: true

require "rails/generators"
require "rails/generators/active_record/migration/migration_generator"

require_relative "../../fx_helper"
require_relative "../../inject_sql"

module Logidze
  module Generators
    module Mysql
      class ModelGenerator < ::ActiveRecord::Generators::Base # :nodoc:
        include InjectSql
        include FxHelper

        source_root File.expand_path("templates", __dir__)
        source_paths << File.expand_path("triggers", __dir__)

        class_option :only, type: :array, required: true,
          desc: "Specify model keys to track"

        class_option :except, type: :array, optional: true,
          desc: "Not supported for MySQL"

        class_option :limit, type: :numeric, optional: true,
          desc: "Specify history size limit"

        class_option :debounce_time, type: :numeric, optional: true,
          desc: "Specify debounce time in millisecond"

        class_option :backfill, type: :boolean, optional: true,
          desc: "Add query to backfill existing records history"

        class_option :only_trigger, type: :boolean, optional: true,
          desc: "Create trigger-only migration"

        class_option :path, type: :string, optional: true,
          desc: "Specify path to the model file"

        class_option :timestamp_column, type: :string, optional: true,
          desc: "Specify timestamp column"

        class_option :name, type: :string, optional: true,
          desc: "Migration name"

        class_option :update, type: :boolean, optional: true,
          desc: "Define whether this is an update migration"

        class_option :after_trigger, type: :boolean, optional: true,
          desc: "Not implemented for MySQL"

        def generate_migration
          if options[:except]
            warn "MySQL does not supports --expect. Use --only"
            exit(1)
          end

          if options[:after_trigger]
            warn "MySQL does not supports --after_trigger."
            exit(1)
          end

          migration_template "migration.rb.erb", "db/migrate/#{migration_name}.rb"
        end

        def inject_logidze_to_model
          return if update?

          indents = "  " * (class_name.scan("::").count + 1)

          inject_into_class(model_file_path, class_name.demodulize, "#{indents}has_logidze\n")
        end

        no_tasks do
          def migration_name
            return options[:name] if options[:name].present?

            if update?
              "update_logidze_for_#{plural_table_name}"
            else
              "add_logidze_to_#{plural_table_name}"
            end
          end

          def full_table_name
            config = ActiveRecord::Base
            "#{config.table_name_prefix}#{table_name}#{config.table_name_suffix}"
          end

          def backfill?
            options[:backfill]
          end

          def only_trigger?
            options[:only_trigger]
          end

          def limit
            options[:limit]
          end

          def update?
            options[:update]
          end

          def logidze_logger_parameters(trigger_type)
            [
              "old_j",
              "new_j",
              columns_json,
              escape_string(trigger_type),
              limit.presence || "NULL"
            ].compact.join(", ")
          end

          def logidze_snapshot_parameters
            [
              json_object(table_fields("t", filtered_columns)),
              columns_json
            ].join(", ")
          end

          def new_json
            json_object(table_fields("NEW", filtered_columns))
          end

          def old_json
            json_object(table_fields("OLD", filtered_columns))
          end

          def columns_json
            json_array(filtered_columns.map { |field| escape_string(field) })
          end

          def table_fields(table, fields)
            fields.flat_map { |field| [escape_string(field), "#{table}.#{field}"] }
          end

          def filtered_columns
            options[:only] + ["log_data"]
          end

          def json_object(array)
            "JSON_OBJECT(" + array.join(", ") + ")"
          end

          def json_array(array)
            "JSON_ARRAY(" + array.join(", ") + ")"
          end

          def escape_string(string)
            return if string.blank?

            "'#{string}'"
          end

          def backticks(string)
            return if string.blank?

            "`#{string}`"
          end
        end

        private

        def model_file_path
          options[:path] || File.join("app", "models", "#{file_path}.rb")
        end
      end
    end
  end
end
