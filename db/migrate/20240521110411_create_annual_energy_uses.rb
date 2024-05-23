class CreateAnnualEnergyUses < ActiveRecord::Migration[6.1]
  def change
    create_view :annual_energy_uses
  end
end
