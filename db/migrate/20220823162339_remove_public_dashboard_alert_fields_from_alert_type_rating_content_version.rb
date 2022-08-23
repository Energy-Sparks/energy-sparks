class RemovePublicDashboardAlertFieldsFromAlertTypeRatingContentVersion < ActiveRecord::Migration[6.0]
  def change
    remove_column :alert_type_rating_content_versions, :public_dashboard_alert_end_date, :date
    remove_column :alert_type_rating_content_versions, :public_dashboard_alert_start_date, :date
    remove_column :alert_type_rating_content_versions, :public_dashboard_alert_weighting, :decimal, default: 5.0
  end
end
