# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.random(num = 1)
    rel = order("rand()")
    (num == 1) ? rel.first : rel.limit(num)
  end
end
