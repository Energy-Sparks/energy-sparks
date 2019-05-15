class AddAlertTypeRatingContentVersionTimings < ActiveRecord::Migration[6.0]
  def change
    add_column :alert_type_rating_content_versions, :find_out_more_start_date, :date
    add_column :alert_type_rating_content_versions, :find_out_more_end_date, :date
    add_column :alert_type_rating_content_versions, :teacher_dashboard_alert_start_date, :date
    add_column :alert_type_rating_content_versions, :teacher_dashboard_alert_end_date, :date
    add_column :alert_type_rating_content_versions, :pupil_dashboard_alert_start_date, :date
    add_column :alert_type_rating_content_versions, :pupil_dashboard_alert_end_date, :date
    add_column :alert_type_rating_content_versions, :sms_start_date, :date
    add_column :alert_type_rating_content_versions, :sms_end_date, :date
    add_column :alert_type_rating_content_versions, :email_start_date, :date
    add_column :alert_type_rating_content_versions, :email_end_date, :date
  end
end
