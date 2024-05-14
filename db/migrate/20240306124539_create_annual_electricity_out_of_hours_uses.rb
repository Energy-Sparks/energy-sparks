class CreateAnnualElectricityOutOfHoursUses < ActiveRecord::Migration[6.1]
  def change
    create_view :annual_electricity_out_of_hours_uses
  end
end
