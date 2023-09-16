# frozen_string_literal: true

ENV["RAILS_ENV"] = "test"

begin
  require "debug" unless ENV["CI"] == "true"
  require "debug/open_nonstop"
rescue LoadError # rubocop:disable Lint/HandleExceptions
end

require "ammeter"
require "timecop"

require File.expand_path("dummy/config/environment", __dir__)

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].sort.each { |f| require f }

RSpec.configure do |config|
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.example_status_persistence_file_path = "tmp/rspec_examples.txt"
  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  config.order = :random
  Kernel.srand config.seed

  config.define_derived_metadata(file_path: %r{/spec/sql/}) do |metadata|
    metadata[:type] = :sql
  end

  config.include Logidze::TestHelpers

  config.before(:each, db: true) do
    ActiveRecord::Base.connection.begin_transaction(joinable: false)
  end

  config.append_after(:each, db: true) do |ex|
    ActiveRecord::Base.connection.rollback_transaction

    raise "Migrations are pending: #{ex.metadata[:location]}" if ActiveRecord::Base.connection.migration_context.needs_migration?
  end
end

class Thor
  class Argument #:nodoc:
    VALID_TYPES = [:numeric, :hash, :array, :string]

    attr_reader :name, :description, :enum, :required, :type, :default, :banner
    alias_method :human_name, :name

    def initialize(name, options = {})
      class_name = self.class.name.split("::").last

      type = options[:type]

      raise ArgumentError, "#{class_name} name can't be nil."                         if name.nil?
      raise ArgumentError, "Type :#{type} is not valid for #{class_name.downcase}s."  if type && !valid_type?(type)

      @name        = name.to_s
      @description = options[:desc]
      @required    = options.key?(:required) ? options[:required] : true
      @type        = (type || :string).to_sym
      @default     = options[:default]
      @banner      = options[:banner] || default_banner
      @enum        = options[:enum]

      # debugger if name == :name

      validate! # Trigger specific validations
    end
  end
end
