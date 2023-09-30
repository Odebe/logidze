# frozen_string_literal: true

require_relative "../abstract/setting"

module Logidze
  module Implementation
    module Pg
      module Setting
        class Wrapper < Abstract::Setting::Wrapper
          def db_set_setting_param
            connection.execute "SET LOCAL #{name} TO #{value};"
          end

          def db_clear_setting_param
            connection.execute "SET LOCAL #{name} TO DEFAULT;"
          end
        end
      end
    end
  end
end
