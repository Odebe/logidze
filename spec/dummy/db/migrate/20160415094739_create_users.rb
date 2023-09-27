# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[5.0]
  include DatabaseHelpers

  def change
    create_table :users do |t|
      t.string :name
      t.integer :age
      t.boolean :active

      if postgresql?
        t.jsonb :extra
        t.string :settings, array: true
        t.jsonb :log_data
      end

      if mysql?
        t.json :extra
        t.json :settings
        t.json :log_data
      end

      t.timestamp :time
    end
  end
end
