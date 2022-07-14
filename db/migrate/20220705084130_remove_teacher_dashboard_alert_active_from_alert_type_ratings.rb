class RemoveTeacherDashboardAlertActiveFromAlertTypeRatings < ActiveRecord::Migration[6.0]
  def change
    remove_column :alert_type_ratings, :teacher_dashboard_alert_active, :boolean, default: false
  end
end
