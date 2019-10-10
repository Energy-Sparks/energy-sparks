class RenameDescriptionForVariousContents < ActiveRecord::Migration[6.0]
  def change
    rename_column :equivalence_type_content_versions, :equivalence, :_equivalence
    change_column_null :equivalence_type_content_versions, :_equivalence, true

    rename_column :alert_type_rating_content_versions, :email_content, :_email_content
    rename_column :alert_type_rating_content_versions, :find_out_more_content, :_find_out_more_content
    rename_column :alert_type_rating_content_versions, :management_priorities_title, :_management_priorities_title
    rename_column :alert_type_rating_content_versions, :management_dashboard_title, :_management_dashboard_title
    rename_column :alert_type_rating_content_versions, :public_dashboard_title, :_public_dashboard_title
    rename_column :alert_type_rating_content_versions, :pupil_dashboard_title, :_pupil_dashboard_title
    rename_column :alert_type_rating_content_versions, :teacher_dashboard_title, :_teacher_dashboard_title

    rename_column :observations, :description, :_description
  end
end
