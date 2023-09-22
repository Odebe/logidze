# frozen_string_literal: true

module Logidze # :nodoc:
  # Provide methods to attach meta information
  module Meta
    def with_meta(meta, transactional: true, &block)
      wrapper =
        if transactional
          Implementation::Current::Meta::WithTransaction
        else
          Implementation::Current::Meta::WithoutTransaction
        end

      wrapper.wrap_with(meta, &block)
    end

    def with_responsible(responsible_id, transactional: true, &block)
      return yield if responsible_id.nil?

      meta = {Logidze::History::Version::META_RESPONSIBLE => responsible_id}
      with_meta(meta, transactional: transactional, &block)
    end
  end
end
