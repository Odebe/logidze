# frozen_string_literal: true

class CreateComments < ActiveRecord::Migration[5.0]
  include DatabaseHelpers

  def change
    create_table :comments do |t|
      t.text :content

      if postgresql?
        t.jsonb :log_data
      end

      if mysql?
        t.json :log_data
      end

      t.references :article, foreign_key: true

      t.timestamps null: false
    end
  end
end
