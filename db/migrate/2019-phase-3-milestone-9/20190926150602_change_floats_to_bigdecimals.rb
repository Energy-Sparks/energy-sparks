class ChangeFloatsToBigdecimals < ActiveRecord::Migration[6.0]
  def change
    change_column :alert_subscription_events, :priority, :decimal
    change_column :dashboard_alerts, :priority, :decimal
    change_column :management_priorities, :priority, :decimal

    change_column :alert_type_rating_content_versions, :email_weighting, :decimal
    change_column :alert_type_rating_content_versions, :sms_weighting, :decimal
    change_column :alert_type_rating_content_versions, :management_dashboard_alert_weighting, :decimal
    change_column :alert_type_rating_content_versions, :management_priorities_weighting, :decimal
    change_column :alert_type_rating_content_versions, :pupil_dashboard_alert_weighting, :decimal
    change_column :alert_type_rating_content_versions, :public_dashboard_alert_weighting, :decimal
    change_column :alert_type_rating_content_versions, :teacher_dashboard_alert_weighting, :decimal
    change_column :alert_type_rating_content_versions, :find_out_more_weighting, :decimal
  end
end
