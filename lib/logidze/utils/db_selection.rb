# frozen_string_literal: true

module Logidze
  module Utils
    module DbSelection
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
      end

      Adapter =
        case adapter_name
        when "postgresql"
          require_relative "adapters/postgres"

          Adapters::Postgres
        else
          raise "Not supported database '#{adapter_name}'"
        end
    end
  end
end
