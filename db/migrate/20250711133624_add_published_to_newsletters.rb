class AddPublishedToNewsletters < ActiveRecord::Migration[7.2]
  def up
    add_column :newsletters, :published, :boolean, null: false, default: false

    add_reference :newsletters, :created_by, foreign_key: { on_delete: :nullify, to_table: :users }
    add_reference :newsletters, :updated_by, foreign_key: { on_delete: :nullify, to_table: :users }

    Newsletter.update_all(published: true)
  end

  def down
    remove_reference :newsletters, :updated_by
    remove_reference :newsletters, :created_by

    remove_column :newsletters, :published
  end
end
