class AddObservationTypeToObservations < ActiveRecord::Migration[6.0]
  def change
    add_column :observations, :observation_type, :integer
    reversible do |dir|
      dir.up do
        connection.execute 'UPDATE observations SET observation_type = 0' # temperature_recording
      end
    end
    change_column_null :observations, :observation_type, false
  end
end
