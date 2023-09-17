# frozen_string_literal: true

require "logidze/utils/db_selection"

module Logidze
  module DbSelectionHelpers # :nodoc:
    def current_db_adapter
      Logidze::Utils::DbSelection.adapter_name
    end

    extend self # rubocop: disable all
  end
end
