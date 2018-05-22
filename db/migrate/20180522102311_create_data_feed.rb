class CreateDataFeed < ActiveRecord::Migration[5.2]
  def change
    create_table :data_feeds do |t|
      t.text    :type, null: false
      t.integer :regional_area_id
      t.text    :regional_area_type
      t.text    :title
      t.text    :description
    end
  end
end
