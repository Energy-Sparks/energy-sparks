class UpdateComparisonElectricityConsumptionDuringHolidaysToVersion4 < ActiveRecord::Migration[7.2]
  def change
    update_view :comparison_electricity_consumption_during_holidays,
      version: 4,
      revert_to_version: 3,
      materialized: true
  end
end
