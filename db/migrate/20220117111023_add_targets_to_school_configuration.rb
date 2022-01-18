class AddTargetsToSchoolConfiguration < ActiveRecord::Migration[6.0]
  def change
    add_column :configurations, :school_target_fuel_types, :string, array: true, null: false, default: []
  end
end
