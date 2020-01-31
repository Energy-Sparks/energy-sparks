class AddResourceFileTypes < ActiveRecord::Migration[6.0]
  def change
    create_table :resource_file_types do |t|
      t.string :title, null: false
      t.integer :position, null: false
      t.timestamps
    end

    add_reference :resource_files, :resource_file_type, foreign_key: {on_delete: :restrict}
  end
end
