class AddMeterSystemToMeter < ActiveRecord::Migration[6.0]
  def change
    add_column :meters, :meter_system, :integer, default: 0 # enum defaults to :nhh_amr
  end
end
