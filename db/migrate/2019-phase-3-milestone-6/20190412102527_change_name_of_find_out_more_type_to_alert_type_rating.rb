class ChangeNameOfFindOutMoreTypeToAlertTypeRating < ActiveRecord::Migration[5.2]
  def change
    rename_table :find_out_more_types, :alert_type_ratings
    rename_table :find_out_more_type_content_versions, :alert_type_rating_content_versions
    rename_column :alert_type_rating_content_versions, :find_out_more_type_id, :alert_type_rating_id
    rename_column :find_out_mores, :find_out_more_type_content_version_id, :alert_type_rating_content_version_id
  end
end
