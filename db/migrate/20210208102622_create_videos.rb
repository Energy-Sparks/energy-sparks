class CreateVideos < ActiveRecord::Migration[6.0]
  def change
    create_table :videos do |t|
      t.text :youtube_id, null: false
      t.text :title, null: false
      t.text :description
      t.boolean :featured, null: false, default: true
      t.integer :position, null: false, default: 1
      t.timestamps
    end
  end
end
