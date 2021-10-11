class ChangeCadsDefaults < ActiveRecord::Migration[6.0]
  def change
    change_column_default :cads, :max_power, 3
    change_column_default :cads, :refresh_interval, 5
  end
end
