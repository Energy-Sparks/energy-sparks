class ChangeIntegerLimitOnMeters < ActiveRecord::Migration[5.0]
  def change
    change_column :meters, :meter_no, :integer, limit: 8
  end
end
