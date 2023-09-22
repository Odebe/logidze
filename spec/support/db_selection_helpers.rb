# frozen_string_literal: true

require "logidze/implementation"

module Logidze
  module DbSelectionHelpers # :nodoc:
    def current_db_adapter
      Logidze::Implementation.adapter_name
    end

    def postgresql?
      current_db_adapter == 'postgresql'
    end

    def mysql?
      current_db_adapter == 'mysql2'
    end
  end
end
