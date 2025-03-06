class CreateThermostaticControls < ActiveRecord::Migration[6.1]
  def change
    create_view :thermostatic_controls
  end
end
