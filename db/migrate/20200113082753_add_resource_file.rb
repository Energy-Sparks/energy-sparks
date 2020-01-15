class AddResourceFile < ActiveRecord::Migration[6.0]
  def change
    create_table :resource_files do |t|
      t.string :title, null: false
      t.timestamps
    end
  end
end
