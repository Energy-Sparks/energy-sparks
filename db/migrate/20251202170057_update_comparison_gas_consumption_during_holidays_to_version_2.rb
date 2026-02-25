class UpdateComparisonGasConsumptionDuringHolidaysToVersion2 < ActiveRecord::Migration[7.2]
  def change
    update_view :comparison_gas_consumption_during_holidays,
      version: 2,
      revert_to_version: 1,
      materialized: true
  end
end
