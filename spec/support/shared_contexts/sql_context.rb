# frozen_string_literal: true

# Helpers for SQL functions testing
module Logidze
  module SqlHelpers
    # Perform SQL query and return the results
    def sql(query)
      result = ::ActiveRecord::Base.connection.execute query
      values = result.respond_to?(:values) ? result.values : result
      values.first&.first
    end
  end
end

RSpec.configure do |config|
  config.include Logidze::SqlHelpers, type: :sql
end
