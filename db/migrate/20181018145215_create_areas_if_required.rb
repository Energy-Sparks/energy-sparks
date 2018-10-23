class CreateAreasIfRequired < ActiveRecord::Migration[5.2]
  def change
    create_table :areas, force: :cascade do |t|
      t.text :type, null: false
      t.text :title
      t.text :description
      t.integer :parent_area_id
      t.index ["parent_area_id"], name: "index_areas_on_parent_area_id"
      t.timestamps
    end unless table_exists?(:areas)
  end
end
