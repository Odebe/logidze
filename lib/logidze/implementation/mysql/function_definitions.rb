# frozen_string_literal: true

require_relative '../abstract/function_definitions'

module Logidze
  module Implementation
    module Mysql
      module FunctionDefinitions
        class << self
          include Abstract::FunctionDefinitions

          private

          def parse_definition(path)
            name = path.match(/([^\/]+)\.sql/)[1]

            file = File.open(path)

            header, _begin_block_start = file.readline, file.readline
            version_comment = file.readline

            signature = parse_signature(header)
            version = parse_version(version_comment)

            [name, version, signature]
          end

          def parse_version(line)
            line.match(/version:\s+(\d+)/)&.[](1).to_i
          end

          def parse_signature(line)
            parameters = line.match(/CREATE FUNCTION\s+[\w_]+\(([^\>]*)\)/)[1]

            parameters
              .split(/\s*,\s*/)
              .map { |param| param.split(/\s+/, 2).last }.join(", ")
          end

          def from_db_query
            <<~SQL
              SELECT ROUTINE_NAME AS proname, ROUTINE_DEFINITION as definition
              FROM information_schema.routines
              WHERE SPECIFIC_NAME like 'logidze_%'
              ORDER BY ROUTINE_NAME;
            SQL
          end

          def function_paths
            find_function_paths('mysql')
          end
        end
      end
    end
  end
end
