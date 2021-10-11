class ChangeCadsDefaults < ActiveRecord::Migration[6.0]
  def up
    change_column :cads, :max_power, :float
    change_column_default :cads, :max_power, 3
    change_column_default :cads, :refresh_interval, 5
  end

  def down
    change_column :cads, :max_power, :integer
    change_column_default :cads, :max_power, 3000
    change_column_default :cads, :refresh_interval, 5000
  end
end
