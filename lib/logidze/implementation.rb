# frozen_string_literal: true

module Logidze
  module Implementation
    class << self
      def adapter_name
        @adapter_name ||=
          begin
            base = ActiveRecord::Base
            config =
              if base.respond_to?(:connection_db_config)
                # 6.1 <= Rails
                base.connection_db_config[:config]
              elsif base.respond_to?(:configurations)
                # 4.1.8 <= Rails < 6.1
                base.configurations[Rails.env]
              else
                raise Logidze::CantDefineDatabase
              end

            raise Logidze::NoConfigForCurrentEnvError, "No database configuration for #{Rails.env}" unless config

            config.with_indifferent_access[:adapter]
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
