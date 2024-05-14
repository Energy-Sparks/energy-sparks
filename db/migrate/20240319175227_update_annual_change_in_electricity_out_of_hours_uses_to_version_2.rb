class UpdateAnnualChangeInElectricityOutOfHoursUsesToVersion2 < ActiveRecord::Migration[6.1]
  def change
    update_view :annual_change_in_electricity_out_of_hours_uses, version: 2, revert_to_version: 1
  end
end
