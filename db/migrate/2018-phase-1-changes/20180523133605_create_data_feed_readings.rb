class CreateDataFeedReadings < ActiveRecord::Migration[5.2]
  def change
    create_table :data_feed_readings do |t|
      t.references  :data_feed, foreign_key: true
      t.integer     :feed_type
      t.datetime    :at, index: true
      t.decimal     :value
      t.string      :unit
      t.timestamps
    end
  end
end
