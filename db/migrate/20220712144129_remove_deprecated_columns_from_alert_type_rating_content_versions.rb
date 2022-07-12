class RemoveDeprecatedColumnsFromAlertTypeRatingContentVersions < ActiveRecord::Migration[6.0]
  def change
    remove_column :alert_type_rating_content_versions, :_email_content, :text
    remove_column :alert_type_rating_content_versions, :_find_out_more_content, :text
    remove_column :alert_type_rating_content_versions, :_management_priorities_title, :text
    remove_column :alert_type_rating_content_versions, :_management_dashboard_title, :text
    remove_column :alert_type_rating_content_versions, :_public_dashboard_title, :text
    remove_column :alert_type_rating_content_versions, :_pupil_dashboard_title, :text
  end
end
