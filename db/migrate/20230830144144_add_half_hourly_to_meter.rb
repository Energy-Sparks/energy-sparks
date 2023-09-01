class AddHalfHourlyToMeter < ActiveRecord::Migration[6.0]
  def change
    add_column :meters, :half_hourly, :boolean, default: true
  end
end
