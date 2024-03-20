class CreateAnnualChangeInGasOutOfHoursUses < ActiveRecord::Migration[6.1]
  def change
    create_view :annual_change_in_gas_out_of_hours_uses
  end
end
