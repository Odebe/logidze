# frozen_string_literal: true

require "logidze/implementation"

module Logidze
  module Generators
    module AdapterHelper
      def db_subtask_name
        self.class::REGISTRY.fetch(database_type) { raise "Not supported database '#{database_type}'" }
      end

      def database_type
        Logidze::Implementation.database_type
      end
    end
  end
end
