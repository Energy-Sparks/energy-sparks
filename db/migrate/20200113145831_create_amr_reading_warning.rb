class CreateAmrReadingWarning < ActiveRecord::Migration[6.0]
  def change
    create_table :amr_reading_warnings do |t|
      t.references  :amr_data_feed_import_log,  foreign_key: { on_delete: :cascade }, null: false
      t.integer     :warning
      t.text        :warning_message
      t.text        :reading_date
      t.text        :mpan_mprn
      t.text        :readings, array: true
      t.timestamps
    end
  end
end
