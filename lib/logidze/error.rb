# frozen_string_literal: true

module Logidze
  class Error < StandardError; end

  # Raises when feature not implemented for specific database
  class NotImplemented < Error; end
end
