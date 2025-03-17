class AddCmsModels < ActiveRecord::Migration[7.2]
  def change
    create_table :cms_categories do |t|
      t.string :icon
      t.string :slug, null: false
      t.boolean :published, null: false, default: false
      t.references :created_by, foreign_key: { on_delete: :nullify, to_table: :users }
      t.references :updated_by, foreign_key: { on_delete: :nullify, to_table: :users }
      t.timestamps
    end

    create_enum :audience, ["anyone", "school_users", "school_admins", "group_admins"]

    create_table :cms_pages do |t|
      t.references :category, null: false, foreign_key: { to_table: :cms_categories }
      t.string :slug, null: false
      t.boolean :published, null: false, default: false
      t.enum :audience, enum_type: :audience, default: "anyone", null: false
      t.references :created_by, foreign_key: { on_delete: :nullify, to_table: :users }
      t.references :updated_by, foreign_key: { on_delete: :nullify, to_table: :users }
      t.timestamps
    end

    create_table :cms_sections do |t|
      t.references :page, null: true, foreign_key: { to_table: :cms_pages }
      t.string :slug, null: false
      t.integer :position, null: true
      t.boolean :published, null: false, default: false
      t.references :created_by, foreign_key: { on_delete: :nullify, to_table: :users }
      t.references :updated_by, foreign_key: { on_delete: :nullify, to_table: :users }
      t.timestamps
    end
  end
end
