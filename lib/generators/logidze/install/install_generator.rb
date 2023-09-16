# frozen_string_literal: true

require "rails/generators"
require "rails/generators/active_record"

require_relative "../adapter_helper"

require_relative "pg/install_generator"

module Logidze
  module Generators
    class InstallGenerator < ::Rails::Generators::Base # :nodoc:
      include Rails::Generators::Migration

      include AdapterHelper

      REGISTRY = {
        "postgresql" => "logidze:pg:install"
      }.freeze

      def select_and_call_generator
        invoke db_subtask_name
      end
    end
  end
end
