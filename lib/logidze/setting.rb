# frozen_string_literal: true

module Logidze # :nodoc:
  module Setting
    def with_logidze_setting(name, value)
      Implementation::Current::Setting::Wrapper.wrap_with(name, value) { yield }
    end
  end
end
