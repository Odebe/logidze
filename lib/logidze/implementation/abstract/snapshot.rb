# frozen_string_literal: true

module Logidze
  module Implementation
    module Abstract
      class Snapshot
        def self.create(model, **opts)
          new(model, opts).call
        end

        def initialize(model, opts)
          @model = model
          @opts = opts
        end

        def call
          model.without_logging do
            process_scope(model.where(log_data: nil))
          end
        end

        private

        def process_scope(_scope)
          raise 'abstract method'
        end
      end
    end
  end
end
