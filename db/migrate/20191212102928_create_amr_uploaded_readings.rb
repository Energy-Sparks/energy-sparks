class CreateAmrUploadedReadings < ActiveRecord::Migration[6.0]
  def change
    create_table :amr_uploaded_readings do |t|
      t.references  :amr_data_feed_config, foreign_key: { on_delete: :cascade }, null: false
      t.boolean     :imported,             default: false,                       null: false
      t.text        :file_name,            default: false,                       null: false
      t.json        :reading_data,         default: {},                          null: false
      t.timestamps
    end
  end
end
