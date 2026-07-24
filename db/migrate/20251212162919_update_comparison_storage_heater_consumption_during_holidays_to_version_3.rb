class UpdateComparisonStorageHeaterConsumptionDuringHolidaysToVersion3 < ActiveRecord::Migration[7.2]
  def change
    update_view :comparison_storage_heater_consumption_during_holidays,
      version: 3,
      revert_to_version: 2,
      materialized: true
  end
end
