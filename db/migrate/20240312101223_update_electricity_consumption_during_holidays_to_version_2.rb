class UpdateElectricityConsumptionDuringHolidaysToVersion2 < ActiveRecord::Migration[6.1]
  def change
    update_view :electricity_consumption_during_holidays, version: 2, revert_to_version: 1
  end
end
