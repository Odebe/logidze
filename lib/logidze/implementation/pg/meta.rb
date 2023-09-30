# frozen_string_literal: true

require_relative "../abstract/meta"

module Logidze
  module Implementation
    module Pg
      module Meta
        class WithTransaction < Abstract::Meta::Wrapper # :nodoc:
          private

          def call_block_in_meta_context
            connection.transaction { super }
          end

          def db_set_meta_param(value)
            connection.execute("SET LOCAL logidze.meta = #{encode_meta(value)};")
          end

          def db_clear_meta_param
            connection.execute("SET LOCAL logidze.meta TO DEFAULT;")
          end
        end

        class WithoutTransaction < Abstract::Meta::Wrapper # :nodoc:
          private

          def db_set_meta_param(value)
            connection.execute("SET logidze.meta = #{encode_meta(value)};")
          end

          def db_clear_meta_param
            connection.execute("SET logidze.meta TO DEFAULT;")
          end
        end
      end
    end
  end
end
