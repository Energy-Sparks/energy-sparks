class AddNotNullConstraintForActivityInProgrammeActivities < ActiveRecord::Migration[6.0]
  def change
    change_column_null :programme_activities, :activity_id, false
  end
end
