class UpdateComparisonGasConsumptionDuringHolidaysToVersion3 < ActiveRecord::Migration[7.2]
  def change
    update_view :comparison_gas_consumption_during_holidays,
      version: 3,
      revert_to_version: 2,
      materialized: true
  end
end
