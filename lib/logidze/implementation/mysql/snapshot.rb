# frozen_string_literal: true

require_relative "../abstract/snapshot"

module Logidze
  module Implementation
    module Mysql
      class Snapshot < Abstract::Snapshot
        def perform
          # Common interface options validation
          raise ArgumentError, "missing required option :only" if opts[:only].blank?
          raise ArgumentError, "not supported option :except" if opts[:except].present?
          raise ArgumentError, "not implemented option :timestamp" if opts[:timestamp].present?

          super
        end

        private

        def process_scope
          scope.update_all(
            <<~SQL
              log_data = logidze_snapshot(#{json_object}, #{json_columns})
            SQL
          )
        end

        # JSON_OBJECT('a', table.a, 'b', table.b)
        def json_object
          arguments = opts[:only].map { |col| "'#{col}', #{scope.quoted_table_name}.#{col}" }.join(", ")

          "JSON_OBJECT(#{arguments})"
        end

        # JSON_ARRAY('a', 'b')
        def json_columns
          arguments = opts[:only].map { |e| "'#{e}'" }.join(", ")

          "JSON_ARRAY(#{arguments})"
        end
      end
    end
  end
end
