class AddManagementPrioritiesFieldsToAlertContent < ActiveRecord::Migration[6.0]
  def change
    add_column :alert_type_ratings, :management_priorities_active, :boolean, default: false
    add_column :alert_type_rating_content_versions, :management_priorities_title, :string
    add_column :alert_type_rating_content_versions, :management_priorities_start_date, :date
    add_column :alert_type_rating_content_versions, :management_priorities_end_date, :date
  end
end
