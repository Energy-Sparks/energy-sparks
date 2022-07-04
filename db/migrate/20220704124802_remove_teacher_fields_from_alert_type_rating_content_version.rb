class RemoveTeacherFieldsFromAlertTypeRatingContentVersion < ActiveRecord::Migration[6.0]
  def change
    remove_column :alert_type_rating_content_versions, :_teacher_dashboard_title
    remove_column :alert_type_rating_content_versions, :teacher_dashboard_alert_end_date
    remove_column :alert_type_rating_content_versions, :teacher_dashboard_alert_start_date
    remove_column :alert_type_rating_content_versions, :teacher_dashboard_alert_weighting
  end
end
