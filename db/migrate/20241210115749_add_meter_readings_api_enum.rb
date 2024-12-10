class AddMeterReadingsApiEnum < ActiveRecord::Migration[7.1]
  def change
    create_enum :meter_readings_api, ['perse_half_hourly']
    add_column :meters, :readings_api, :enum, enum_type: :meter_readings_api
  end
end
