# frozen_string_literal: true

class CreateIssueTags < ActiveRecord::Migration[8.1]
  def change
    create_table :issue_tags do |t|
      t.string :system_id, index: { unique: true }
      t.string :label, index: { unique: true }

      t.timestamps
    end

    create_table :issue_tags_issues do |t|
      t.belongs_to :issue_tag
      t.belongs_to :issue

      t.timestamps
    end
  end
end
