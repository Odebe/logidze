# frozen_string_literal: true

require_relative '../implementation/load'

module Logidze
  module Utils
    module FunctionDefinitions
      class << self
        delegate :from_fs, :from_db, to: Implementation::Current::FunctionDefinitions
      end
    end
  end
end
