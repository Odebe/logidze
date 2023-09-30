# frozen_string_literal: true

module Logidze
  module Implementation
    module Abstract
      module Setting
        class Wrapper
          attr_reader :name, :value, :block

          delegate :connection, :transaction, to: ActiveRecord::Base

          def self.wrap_with(name, value, &block)
            new(name, value, block).perform
          end

          def initialize(name, value, block)
            @name = name
            @value = value
            @block = block
          end

          def perform
            within_transaction do
              within_setting do
                block.call
              end
            end
          end

          private

          def within_setting
            db_set_setting_param

            yield.tap { db_clear_setting_param }
          end

          def within_transaction
            transaction { yield }
          end

          def db_set_setting_param
            raise "abstract method"
          end

          def db_clear_setting_param
            raise "abstract method"
          end
        end
      end
    end
  end
end
