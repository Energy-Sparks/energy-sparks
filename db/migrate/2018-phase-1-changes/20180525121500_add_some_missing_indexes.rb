class AddSomeMissingIndexes < ActiveRecord::Migration[5.2]
  def change
    add_index :activity_type_suggestions, :suggested_type_id
    add_index :calendars, :based_on_id
    add_index :data_feeds, :area_id
    add_index :merit_actions, :user_id
    add_index :merit_scores, :sash_id unless index_exists?(:merit_scores, :sash_id)
    add_index :merit_activity_logs, %i[related_change_id related_change_type], name: 'merit_activity_logs_for_related_changes'
  end
end
