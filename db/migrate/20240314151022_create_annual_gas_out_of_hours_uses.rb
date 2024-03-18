class CreateAnnualGasOutOfHoursUses < ActiveRecord::Migration[6.1]
  def change
    create_view :annual_gas_out_of_hours_uses
  end
end
