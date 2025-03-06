class CreateElectricityConsumptionDuringHolidays < ActiveRecord::Migration[6.1]
  def change
    create_view :electricity_consumption_during_holidays
  end
end
