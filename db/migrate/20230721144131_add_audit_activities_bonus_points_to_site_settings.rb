class AddAuditActivitiesBonusPointsToSiteSettings < ActiveRecord::Migration[6.0]
  def change
    add_column :site_settings, :audit_activities_bonus_points, :integer, default: 0
  end
end
