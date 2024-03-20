class CreateThermostatSensitivities < ActiveRecord::Migration[6.1]
  def change
    create_view :thermostat_sensitivities
  end
end
