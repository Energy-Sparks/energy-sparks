class MigrateFromMerit < ActiveRecord::Migration[6.0]
  def up
    remove_column :activity_types, :badge_name
    remove_column :activity_categories, :badge_name
    remove_column :schools, :sash_id

    add_column :activities, :points, :integer, default: 0

    connection.execute(
      "UPDATE activities SET points = (SELECT SUM(merit_score_points.num_points) FROM merit_score_points " \
      "INNER JOIN merit_activity_logs ON merit_activity_logs.related_change_id = merit_score_points.id AND merit_activity_logs.related_change_type = 'Merit::Score::Point' " \
      "INNER JOIN merit_actions ON merit_activity_logs.action_id = merit_actions.id AND merit_actions.target_model = 'activities' AND merit_actions.target_id = activities.id)"
    )

    drop_table :merit_actions
    drop_table :merit_activity_logs
    drop_table :merit_scores
    drop_table :sashes
    drop_table :merit_score_points
    drop_table :badges_sashes
  end
end
