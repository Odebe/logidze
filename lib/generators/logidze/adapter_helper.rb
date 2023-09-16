# frozen_string_literal: true

require "logidze/utils/db_selection"

module Logidze
  module Generators
    module AdapterHelper
      def db_subtask_name
        self.class::REGISTRY.fetch(adapter_name) { raise "Not supported database '#{adapter_name}'" }
      end

      def adapter_name
        Logidze::Utils::DbSelection.adapter_name
      end
    end
  end
end
