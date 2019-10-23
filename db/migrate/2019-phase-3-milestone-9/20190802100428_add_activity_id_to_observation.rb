class AddActivityIdToObservation < ActiveRecord::Migration[6.0]
  def change
    add_reference :observations, :activity, foreign_key: {on_delete: :cascade}

    reversible do |dir|
      dir.up do
        connection.execute(
          "INSERT INTO observations (activity_id, school_id, observation_type, created_at, updated_at, at) " \
          "SELECT id, school_id, 2, created_at, created_at, happened_on FROM activities"
          )
      end
    end
  end
end
