class MovePointsToObeservations < ActiveRecord::Migration[6.0]
  def up
    add_column :observations, :points, :integer
    connection.execute(
      "UPDATE observations SET points = activities.points FROM activities WHERE observations.activity_id = activities.id"
    )
    remove_column :activities, :points
  end

  def down
    add_column :activities, :points, :integer, default: 0
    connection.execute(
      "UPDATE activities SET points = observations.points FROM observations WHERE observations.activity_id = activities.id"
    )
    remove_column :observations, :points
  end
end
