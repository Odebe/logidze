# frozen_string_literal: true

require "acceptance_helper"

describe "logidze_filter_keys", database: :mysql do
  let(:data) { %q(JSON_UNQUOTE('{"title": "Feel me", "rating": 42, "name": "Jack"}')) }

  specify "only filter" do
    res = sql "select logidze_filter_keys(#{data}, JSON_ARRAY('title', 'rating'))"

    expect(JSON.parse(res)).to eq({"title" => "Feel me", "rating" => 42})
  end
end
