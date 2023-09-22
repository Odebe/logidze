# frozen_string_literal: true

module Logidze
  module Implementation
    module Abstract
      class Snapshot
        def self.create(scope, **opts)
          new(scope, opts).perform
        end

        attr_reader :scope, :opts

        delegate :without_logging, to: Logidze

        def initialize(scope, opts)
          @scope = scope
          @opts = opts
        end

        def perform
          without_logging { process_scope }
        end

        private

        def process_scope
          raise 'abstract method'
        end
      end
    end
  end
end
