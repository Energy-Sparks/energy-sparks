class ChangeTypeOfStartTimeAndEndTime < ActiveRecord::Migration[6.0]
  def change
    remove_column :user_tariff_prices, :start_time, :text
    remove_column :user_tariff_prices, :end_time, :text
    add_column :user_tariff_prices, :start_time, :time, null: false, default: '00:00:00'
    add_column :user_tariff_prices, :end_time, :time, null: false, default: '23:30:00'
  end
end
