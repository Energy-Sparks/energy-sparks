class AddPublicAndManagementAlertContentFields < ActiveRecord::Migration[6.0]
  def change
    add_column :alert_type_ratings, :public_dashboard_alert_active, :boolean, default: false
    add_column :alert_type_rating_content_versions, :public_dashboard_alert_start_date, :date
    add_column :alert_type_rating_content_versions, :public_dashboard_alert_end_date, :date
    add_column :alert_type_rating_content_versions, :public_dashboard_title, :string

    add_column :alert_type_ratings, :management_dashboard_alert_active, :boolean, default: false
    add_column :alert_type_rating_content_versions, :management_dashboard_alert_start_date, :date
    add_column :alert_type_rating_content_versions, :management_dashboard_alert_end_date, :date
    add_column :alert_type_rating_content_versions, :management_dashboard_title, :string
  end
end
