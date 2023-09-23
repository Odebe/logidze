# frozen_string_literal: true

module Logidze
  class Error < StandardError; end

  # Raises when feature not implemented for specific database
  class NotImplemented < Error; end

  # Raises in implementation selection stage
  class ImplementationSelectionError < Error; end

  # Raises when app loaded without current env database config
  class NoConfigForCurrentEnvError < ImplementationSelectionError; end

  class CantDefineDatabase < ImplementationSelectionError; end
end
