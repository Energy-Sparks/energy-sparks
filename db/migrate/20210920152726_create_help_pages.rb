class CreateHelpPages < ActiveRecord::Migration[6.0]
  def change
    create_table :help_pages do |t|
      t.string :title, null: false
      t.integer :feature, null: false
      t.boolean :published, null: false, default: false
      t.string :slug, null: false
      t.timestamps
    end

    add_index :help_pages, :slug, :unique => true
  end
end
