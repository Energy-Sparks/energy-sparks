class RemoveHalfHourlyColumnFromMeter < ActiveRecord::Migration[6.0]
  def change
    remove_column :meters, :half_hourly
  end
end
