# frozen_string_literal: true

module DatabaseHelpers
  extend ActiveSupport::Concern

  included do
    def postgresql?
      %w[postgresql postgres].include? ENV["DB"]
    end

    def mysql?
      ENV["DB"] == 'mysql'
    end
  end
end
