# frozen_string_literal: true

require "acceptance_helper"

describe "logidze_snapshot", database: :mysql2 do
  let(:now) { Time.zone.local(1989, 7, 10, 18, 23, 33) }

  let(:data) { %(JSON_UNQUOTE('{"title": "Feel me", "rating": 42, "name": "Jack", "extra": {"gender": "X"}, "updated_at": "#{now.to_s(:db)}"}')) }

  specify "with columns filtering" do
    res = sql "select logidze_snapshot(#{data}, JSON_ARRAY('name'))"

    snapshot = JSON.parse(res)

    expect(snapshot["v"]).to eq 1
    expect(snapshot["h"].size).to eq 1

    version = snapshot["h"].first

    expect(version)
      .to match({
       "ts" => an_instance_of(Integer),
       "v" => 1,
       "c" => {"name" => "Jack"}
     })

    expect(Time.at(version["ts"] / 1000) - now).to be > 1.year
  end
end
