class CreateEstimatedAnnualConsumptions < ActiveRecord::Migration[6.0]
  def change
    create_table :estimated_annual_consumptions do |t|
      t.integer :year, null: false
      t.float :electricity
      t.float :storage_heaters
      t.float :gas
      t.references :school, null: false, foreign_key: true

      t.timestamps
    end
  end
end
