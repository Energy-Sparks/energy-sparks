class CreateStorageHeaterConsumptionDuringHolidays < ActiveRecord::Migration[6.1]
  def change
    create_view :storage_heater_consumption_during_holidays
  end
end
