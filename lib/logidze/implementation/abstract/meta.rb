# frozen_string_literal: true

module Logidze
  module Implementation
    module Abstract
      module Meta
        class Wrapper # :nodoc:
          def self.wrap_with(meta, &block)
            new(meta, &block).perform
          end

          attr_reader :meta, :block

          delegate :connection, to: ActiveRecord::Base

          def initialize(meta, &block)
            @meta = meta
            @block = block
          end

          def perform
            raise ArgumentError, "Block must be given" unless block
            return block.call if meta.nil?

            call_block_in_meta_context
          end

          def call_block_in_meta_context
            prev_meta = current_meta

            meta_stack.push(meta)

            db_set_meta_param(current_meta)
            result = block.call
            result
          ensure
            db_reset_meta_param(prev_meta)
            meta_stack.pop
          end

          def current_meta
            meta_stack.reduce(:merge) || {}
          end

          def meta_stack
            Thread.current[:meta] ||= []
            Thread.current[:meta]
          end

          def encode_meta(value)
            connection.quote(ActiveSupport::JSON.encode(value))
          end

          def db_reset_meta_param(prev_meta)
            if prev_meta.empty?
              db_clear_meta_param
            else
              db_set_meta_param(prev_meta)
            end
          end
        end
      end
    end
  end
end
