class AddEstimatesToSchoolConfiguration < ActiveRecord::Migration[6.0]
  def change
    add_column :configurations, :suggest_estimates_fuel_types, :string, array: true, null: false, default: []
  end
end
