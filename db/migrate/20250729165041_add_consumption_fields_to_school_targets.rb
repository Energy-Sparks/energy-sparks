class AddConsumptionFieldsToSchoolTargets < ActiveRecord::Migration[7.2]
  def change
    change_table :school_targets, bulk: true do |t|
      t.jsonb :electricity_monthly_consumption
      t.jsonb :gas_monthly_consumption
      t.jsonb :storage_heaters_monthly_consumption
    end
  end
end
