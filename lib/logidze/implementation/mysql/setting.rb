# frozen_string_literal: true

require_relative "../abstract/setting"

module Logidze
  module Implementation
    module Mysql
      module Setting
        class Wrapper < Abstract::Setting::Wrapper

          def within_setting
            db_set_setting_param

            yield
          ensure
            # TODO: create exception handler in sql functions
            db_clear_setting_param
          end

          def db_set_setting_param
            connection.execute "SET @#{name} = '#{value}';"
          end

          def db_clear_setting_param
            connection.execute "SET @#{name} = NULL;"
          end
        end
      end
    end
  end
end
