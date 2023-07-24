class AddPhotoBonusPointsToSiteSettings < ActiveRecord::Migration[6.0]
  def change
    add_column :site_settings, :photo_bonus_points, :integer, default: 0
  end
end
