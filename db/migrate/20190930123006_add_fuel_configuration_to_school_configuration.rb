class AddFuelConfigurationToSchoolConfiguration < ActiveRecord::Migration[6.0]
  def change
    add_column :configurations, :fuel_configuration, :json, default: {}

    reversible do |dir|
      dir.up do
        connection.execute("UPDATE configurations SET fuel_configuration = json_build_object('has_electricity', electricity, 'has_gas', gas, 'fuel_types_for_analysis', 'none')")
      end
      dir.down do
        connection.execute("UPDATE configurations SET electricity = (fuel_configuration->>'electricity')::boolean, gas = (fuel_configuration->>'gas')::boolean")
      end
    end
    remove_column :configurations, :gas, :boolean, default: false
    remove_column :configurations, :electricity, :boolean, default: false
  end
end
