# frozen_string_literal: true

require_relative "../func_def"

module Logidze
  module Utils
    module DbSelection
      module Adapters
        module Mysql
          class << self

            def watched_files_patterns
              [
                File.join(__dir__, "../../..", "generators/logidze/install/mysql/functions/*.sql"),
                File.join(__dir__, "../../..", "generators/logidze/install/mysql/templates/*")
              ]
            end

            def function_paths
              Dir.glob(
                File.join(
                  __dir__, "..", "..", "..", "generators", "logidze", "install", "mysql", "functions", "*.sql"
                )
              )
            end

            def from_fs
              function_paths.map do |path|
                name = path.match(/([^\/]+)\.sql/)[1]

                file = File.open(path)

                header, _begin_block_start = file.readline, file.readline
                version_comment = file.readline

                signature = parse_signature(header)
                version = parse_version(version_comment)

                FuncDef.new(name, version, signature)
              end
            end

            def from_db
              query = <<~SQL
                SELECT ROUTINE_NAME AS proname, ROUTINE_DEFINITION as definition
                FROM information_schema.routines
                WHERE SPECIFIC_NAME like 'logidze_%';
              SQL

              ActiveRecord::Base.connection.execute(query).map do |row|
                version = parse_version(row["definition"])
                # TODO: procedure signature with help of information_schema.parameters
                FuncDef.new(row["proname"], version, nil)
              end
            end

            private

            def parse_version(line)
              line.match(/version:\s+(\d+)/)&.[](1).to_i
            end

            def parse_signature(line)
              parameters = line.match(/CREATE PROCEDURE\s+[\w_]+\(([^\>]*)\)/)[1]

              parameters
                .split(/\s*,\s*/)
                .map { |param| param.split(/\s+/, 2).last }.join(", ")
            end
          end
        end
      end
    end
  end
end
