# frozen_string_literal: true

module Logidze
  module Implementation
    current =
      case database_type
      when "postgresql"
        require_relative "pg"

        Implementation::Pg
      when "mysql"
        require_relative "mysql"

        Implementation::Mysql
      else
        raise "Not supported database '#{adapter_name}'"
      end

    const_set("Current", current)
  end
end
