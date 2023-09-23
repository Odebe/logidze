# frozen_string_literal: true

require_relative "../abstract/snapshot"

module Logidze
  module Implementation
    module Pg
      class Snapshot < Abstract::Snapshot
        private

        def process_scope
          scope.update_all(
            <<~SQL
              log_data = logidze_snapshot(to_jsonb(#{scope.quoted_table_name}), #{args.join(", ")})
            SQL
          )
        end

        def args
          args = ["'null'"]

          args[0] = "'#{opts[:timestamp]}'" if opts[:timestamp]

          columns = opts[:only] || opts[:except]

          if columns
            args[1] = "'{#{opts[:columns].join(",")}}'"
            args[2] = opts[:only] ? "true" : "false"
          end

          args
        end
      end
    end
  end
end
