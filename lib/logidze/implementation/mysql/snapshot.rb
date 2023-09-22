# frozen_string_literal: true

require_relative '../abstract/snapshot'

module Logidze
  module Implementation
    module Pg
      class Snapshot < Abstract::Snapshot
        private

        def process_scope(scope)
          scope
        end
      end
    end
  end
end
