class AddGroupDashboardAlertRatingOptions < ActiveRecord::Migration[7.2]
  def change
    add_column :alert_type_ratings, :group_dashboard_alert_active, :boolean, default: false

    change_table :alert_type_rating_content_versions, bulk: true do |t|
      t.date :group_dashboard_alert_start_date
      t.date :group_dashboard_alert_end_date
      t.decimal :group_dashboard_alert_weighting, default: 5.0
    end
  end
end
