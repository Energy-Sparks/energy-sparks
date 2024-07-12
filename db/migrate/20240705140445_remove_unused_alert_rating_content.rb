class RemoveUnusedAlertRatingContent < ActiveRecord::Migration[7.1]
  def change
    remove_column :alert_type_rating_content_versions, :analysis_start_date, :date
    remove_column :alert_type_rating_content_versions, :analysis_end_date, :date
    remove_column :alert_type_rating_content_versions, :analysis_title, :string
    remove_column :alert_type_rating_content_versions, :analysis_subtitle, :string
    remove_column :alert_type_rating_content_versions, :analysis_weighting, :decimal
    remove_column :alert_type_ratings, :analysis_active, :boolean
  end
end
