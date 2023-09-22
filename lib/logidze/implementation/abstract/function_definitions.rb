# frozen_string_literal: true

module Logidze
  module Implementation
    module Abstract
      module FunctionDefinitions
        class FuncDef < Struct.new(:name, :version, :signature); end

        def from_fs
          function_paths.map do |path|
            name, version, signature = parse_definition(path)

            FuncDef.new(name, version, signature)
          end
        end

        def from_db
          ActiveRecord::Base.connection.exec_query(from_db_query).map do |row|
            version = parse_version(row["definition"])

            FuncDef.new(row["proname"], version, nil)
          end
        end

        private

        def function_paths
          raise 'abstract method'
        end

        def parse_definition(_)
          raise 'abstract method'
        end

        def parse_version(_)
          raise 'abstract method'
        end

        def from_db_query
          raise 'abstract method'
        end

        def find_function_paths(adapter)
          Dir.glob(
            File.join(
              __dir__, "..", "..", "..", "generators", "logidze", "install", adapter, "functions", "*.sql"
            )
          )
        end
      end
    end
  end
end
