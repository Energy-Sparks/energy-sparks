class CreateGasConsumptionDuringHolidays < ActiveRecord::Migration[6.1]
  def change
    create_view :gas_consumption_during_holidays
  end
end
