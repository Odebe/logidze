# frozen_string_literal: true

class CreatePosts < ActiveRecord::Migration[5.0]
  include DatabaseHelpers

  def change
    create_table :posts do |t|
      t.string :title
      t.integer :rating
      t.boolean :active

      if postgresql?
        t.jsonb :meta
        t.jsonb :data
      end

      if mysql?
        t.json :meta
        t.json :data
      end

      t.references :user

      t.timestamps null: false
    end
  end
end
