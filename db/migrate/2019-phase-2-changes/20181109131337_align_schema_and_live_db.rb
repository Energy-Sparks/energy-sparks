class AlignSchemaAndLiveDb < ActiveRecord::Migration[5.2]
  def change
    change_column_null :sashes, :created_at, false
    change_column_null :sashes, :updated_at, false
    change_column_null :merit_actions, :created_at, false
    change_column_null :merit_actions, :updated_at, false
    add_index :merit_score_points, :score_id unless index_exists?(:merit_score_points, :score_id)
  end
end
