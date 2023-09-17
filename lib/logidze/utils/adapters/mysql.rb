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
              []
            end

            def from_db
              []
            end

            private

            def parse_version(line)
              line.match(/version:\s+(\d+)/)&.[](1).to_i
            end

            def parse_signature(line)
              parameters = line.match(/CREATE OR REPLACE FUNCTION\s+[\w_]+\((.*)\)/)[1]
              parameters.split(/\s*,\s*/).map { |param| param.split(/\s+/, 2).last.sub(/\s+DEFAULT .*$/, "") }.join(", ")
            end
          end
        end
      end
    end
  end
end
