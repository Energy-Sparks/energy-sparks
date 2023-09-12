class ChangeMeterHalfHourlyDefault < ActiveRecord::Migration[6.0]
  def change
    change_column_default :meters, :half_hourly, from: true, to: false
  end
end
