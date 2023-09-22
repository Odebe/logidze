# frozen_string_literal: true

require_relative '../abstract/snapshot'

module Logidze
  module Implementation
    module Mysql
      class Snapshot < Abstract::Snapshot
        def perform
          raise Logidze::NotImplemented, "Snapshots not implemented for MySQL"
        end
      end
    end
  end
end
