# frozen_string_literal: true

class CreateIssueTags < ActiveRecord::Migration[8.1]
  def change
    create_table :issue_tags do |t|
      t.string :system_id
      t.string :label

      t.timestamps
    end
  end
end
