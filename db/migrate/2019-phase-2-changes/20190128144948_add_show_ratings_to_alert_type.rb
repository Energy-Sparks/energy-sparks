class AddShowRatingsToAlertType < ActiveRecord::Migration[5.2]
  def change
    add_column :alert_types, :show_ratings, :boolean, default: true
  end
end