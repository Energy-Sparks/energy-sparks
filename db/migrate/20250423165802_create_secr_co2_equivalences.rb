class CreateSecrCo2Equivalences < ActiveRecord::Migration[7.2]
  def change
    create_table :secr_co2_equivalences do |t|
      t.integer :year
      t.float :electricity_co2e
      t.float :transmission_distribution_co2e
      t.float :natural_gas_co2e

      t.timestamps
    end
  end
end
