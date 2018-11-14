class CreateDataFeed < ActiveRecord::Migration[5.2]
  def change
    create_table :data_feeds do |t|
      t.text    :type, null: false
      t.integer :area_id
      t.text    :title
      t.text    :description
      t.json    :configuration, default: {}, null: false
    end
  end
end
