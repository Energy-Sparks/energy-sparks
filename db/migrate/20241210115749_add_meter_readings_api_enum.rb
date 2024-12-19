class AddMeterReadingsApiEnum < ActiveRecord::Migration[7.1]
  def change
    create_enum :meter_perse_api, ['half_hourly']
    add_column :meters, :perse_api, :enum, enum_type: :meter_perse_api
  end
end
