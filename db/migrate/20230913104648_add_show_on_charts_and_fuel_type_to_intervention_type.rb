class AddShowOnChartsAndFuelTypeToInterventionType < ActiveRecord::Migration[6.0]
  def change
    add_column :intervention_types, :show_on_charts, :boolean, default: true
    add_column :intervention_types, :fuel_type, :string, array: true, default: []
  end
end
