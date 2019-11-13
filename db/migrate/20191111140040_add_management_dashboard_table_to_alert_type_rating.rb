class AddManagementDashboardTableToAlertTypeRating < ActiveRecord::Migration[6.0]
  def change
    add_column :alert_type_ratings, :management_dashboard_table_active, :boolean, default: false
    add_column :alert_type_rating_content_versions, :management_dashboard_table_start_date, :date
    add_column :alert_type_rating_content_versions, :management_dashboard_table_end_date, :date
    add_column :alert_type_rating_content_versions, :management_dashboard_table_weighting, :decimal, default: 5.0

    create_table :management_dashboard_tables do |t|
      t.references :content_generation_run, foreign_key: {on_delete: :cascade}
      t.references :alert, foreign_key: {on_delete: :cascade}
      t.references :alert_type_rating_content_version, foreign_key: {on_delete: :restrict}, index: {name: 'man_dash_alert_content_version_index'}
      t.timestamps
    end
  end
end
