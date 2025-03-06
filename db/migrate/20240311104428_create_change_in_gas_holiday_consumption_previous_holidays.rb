class CreateChangeInGasHolidayConsumptionPreviousHolidays < ActiveRecord::Migration[6.1]
  def change
    create_view :change_in_gas_holiday_consumption_previous_holidays
  end
end
