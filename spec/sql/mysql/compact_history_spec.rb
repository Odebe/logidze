# frozen_string_literal: true

require "acceptance_helper"

describe "logidze_compact_history", database: :mysql do
  let(:data) do
    %('
      {
        "v": 3,
        "h": [
          {
            "v": 1,
            "ts": 1460805759352,
            "c": {"title": "Feel me", "rating": 42, "name": "Jack"}
          },
          {
            "v": 2,
            "ts": 1460808759352,
            "c": {"rating": 45, "title": null }
          },
          {
            "v": 3,
            "ts": 1460815759352,
            "c": {"name": "June"}
          }
        ]
      }
    ')
  end

  specify "with null cutoff" do
    res = sql "select logidze_compact_history(JSON_UNQUOTE(#{data}), NULL)"

    hist = JSON.parse(res)

    expect(hist["v"]).to eq 3
    expect(hist["h"].size).to eq 2

    expect(hist["h"].first["v"]).to eq 2
    expect(hist["h"].first["ts"]).to eq 1460808759352
    expect(hist["h"].first["c"]).to eq({"title" => nil, "rating" => 45, "name" => "Jack"})
  end

  specify "with custom cutoff" do
    res = sql "select logidze_compact_history(JSON_UNQUOTE(#{data}), 2)"

    hist = JSON.parse(res)
    expect(hist["v"]).to eq 3
    expect(hist["h"].size).to eq 1

    expect(hist["h"].first["v"]).to eq 3
    expect(hist["h"].first["ts"]).to eq 1460815759352
    expect(hist["h"].first["c"]).to eq({"title" => nil, "rating" => 45, "name" => "June"})
  end

  context "when cutoff equals history size" do
    let(:data) do
      %('
      {
        "v": 1,
        "h": [
          {
            "v": 1,
            "ts": 1460805759352,
            "c": {"title": "Feel me", "rating": 42, "name": "Jack"}
          }
        ]
      }
    ')
    end

    specify "with custom cutoff" do
      res = sql "select logidze_compact_history(JSON_UNQUOTE(#{data}), 1)"
      hist = JSON.parse(res)

      expect(hist).to match({"h" => [{"c" => nil, "v" => nil, "ts" => nil}], "v" => 1})
    end
  end
end
