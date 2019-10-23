class AddIndexToAmrDataFeedReadingsMpanMprn < ActiveRecord::Migration[5.2]
  def change
    add_index :amr_data_feed_readings, :mpan_mprn
  end
end
