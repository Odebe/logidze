# frozen_string_literal: true

require_relative 'db_selection'

module Logidze
  module Utils
    module FunctionDefinitions
      class << self
        delegate :from_fs, :from_db, to: DbSelection::Adapter
      end
    end
  end
end
