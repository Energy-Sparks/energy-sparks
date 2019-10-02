class RemoveContentNullChecks < ActiveRecord::Migration[5.2]
  def change
    change_column_null :alert_type_rating_content_versions, :page_title, true
    change_column_null :alert_type_rating_content_versions, :page_content, true
    change_column_null :alert_type_rating_content_versions, :pupil_dashboard_title, true
    change_column_null :alert_type_rating_content_versions, :teacher_dashboard_title, true
  end
end
