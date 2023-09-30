# frozen_string_literal: true

class CreateArticles < ActiveRecord::Migration[5.0]
  include DatabaseHelpers

  def change
    create_table :articles do |t|
      t.string :title
      t.integer :rating
      t.boolean :active
      t.references :user, foreign_key: true

      if postgresql?
        t.jsonb :log_data
      end

      if mysql?
        t.json :log_data
      end

      t.timestamps null: false
    end
  end
end
