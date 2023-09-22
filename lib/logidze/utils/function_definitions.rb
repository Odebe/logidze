# frozen_string_literal: true

require_relative '../implementation/load'
require_relative '../implementation/abstract/function_definitions'

module Logidze
  module Utils
    FunctionDefinitions = Implementation::Current::FunctionDefinitions
    FuncDef = Implementation::Abstract::FunctionDefinitions::FuncDef
  end
end
