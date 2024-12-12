class NewHelpPages < ActiveRecord::Migration[7.1]
  def change
    create_table :cms_categories do |t|
      t.string :icon
      t.string :slug, null: false
      t.boolean :published, null: false, default: false
      t.timestamps
    end

    create_table :cms_pages do |t|
      t.references :category, null: false, foreign_key: { to_table: :cms_categories }
      t.string :slug, null: false
      t.boolean :published, null: false, default: false
      t.timestamps
    end

    create_table :cms_sections do |t|
      t.references :page, null: false, foreign_key: { to_table: :cms_pages }
      t.string :slug, null: false
      t.integer :position, default: 0, null: false
      t.boolean :published, null: false, default: false
      t.timestamps
    end
  end
end
