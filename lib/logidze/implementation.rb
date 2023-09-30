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
                base.connection_db_config.then do |conf|
                  # Rails >= 7 || (6.1 <= Rails < 7)
                  conf.try(:configuration_hash).presence || conf[:config]
                end
              elsif base.respond_to?(:configurations)
                # 4.1.8 <= Rails < 6.1
                base.configurations[Rails.env]
              else
                raise Logidze::CannotIdentifyDatabase
              end

            raise Logidze::NoConfigForCurrentEnvError, "No database configuration for #{Rails.env}" unless config

            config.with_indifferent_access[:adapter]
          end
      end

      def database_type
        @database_name ||=
          case adapter_name
          when "mysql2", "trilogy"
            "mysql"
          else
            adapter_name
          end
      end
    end
  end
end
