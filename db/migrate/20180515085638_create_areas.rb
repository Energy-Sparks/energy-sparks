class CreateAreas < ActiveRecord::Migration[5.2]
  def change
    create_table :areas do |t|
      t.text      :title
      t.text      :description
      t.integer   :parent_area_id, index: true
    end
  end
end
