# frozen_string_literal: true

module Logidze
  module Implementation
    Current = nil # rubocop: disable Naming/ConstantName

    class << self
      def adapter_name
        @adapter_name ||=
          begin
            base = ActiveRecord::Base

            if base.respond_to?(:connection_db_config)
              # Rails >= 6.1
              base.connection_db_config[:config][:adapter]
            elsif base.respond_to?(:connection_config)
              # Rails < 6.1
              base.establish_connection
              # TODO: maybe close connection
              base.connection_config[:adapter]
            else
              # TODO
              raise "Can't define database adapter name"
            end
          end
      end

      def database_type
        @database_name ||=
          case adapter_name
          when "mysql2"
            "mysql"
          else
            adapter_name
          end
      end
    end
  end
end

require_relative "implementation/load"
