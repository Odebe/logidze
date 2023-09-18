# frozen_string_literal: true

require "rails/generators"
require "rails/generators/active_record"
require "logidze/utils/function_definitions"

require_relative "../../fx_helper"
require_relative "../../inject_sql"

module Logidze
  module Generators
    module Mysql
      class InstallGenerator < ::Rails::Generators::Base # :nodoc:
        include Rails::Generators::Migration

        include InjectSql
        include FxHelper

        source_root File.expand_path("templates", __dir__)
        source_paths << File.expand_path("functions", __dir__)

        class_option :update,
          type: :boolean,
          optional: true,
          desc: "Define whether this is an update migration"

        def generate_migration
          migration_template = fx? ? "migration_fx.rb.erb" : "migration.rb.erb"
          migration_template migration_template, "db/migrate/#{migration_name}.rb"
        end

        def generate_fx_functions
          return unless fx?

          function_definitions.each do |fdef|
            next if fdef.version == previous_version_for(fdef.name)

            template "#{fdef.name}.sql", "db/functions/#{fdef.name}_v#{fdef.version.to_s.rjust(2, "0")}.sql"
          end
        end

        no_tasks do
          def migration_name
            if update?
              "logidze_update_#{Logidze::VERSION.delete(".")}"
            else
              "logidze_install"
            end
          end

          def migration_class_name
            migration_name.classify
          end

          def update?
            options[:update]
          end

          def previous_version_for(name)
            all_functions.filter_map { |path| Regexp.last_match[1].to_i if path =~ %r{#{name}_v(\d+).sql} }.max
          end

          def all_functions
            @all_functions ||=
              begin
                res = nil
                in_root do
                  res =
                    if File.directory?("db/functions")
                      Dir.entries("db/functions")
                    else
                      []
                    end
                end
                res
              end
          end

          # Generate `logidze_logger_after.sql` from the regular `logidze_logger.sql`
          # by find-and-replacing a few lines
          def generate_logidze_logger_after
            source = File.read(File.join(__dir__, "functions", "logidze_logger.sql"))
            source.sub!(/^DROP PROCEDURE IF EXISTS logidze_logger.*$/, "")
            source.sub!(/^CREATE PROCEDURE logidze_logger.*$/, "")
            source.sub!(/^BEGIN$/, "")
            source.sub!(/^-- version.*$/, "")
            source.sub!(/^DELIMITER \$\$/, "")

            source
          end

          def function_definitions
            @function_definitions ||= Logidze::Utils::FunctionDefinitions.from_fs
          end
        end

        def self.next_migration_number(dir)
          ::ActiveRecord::Generators::Base.next_migration_number(dir)
        end
      end
    end
  end
end
