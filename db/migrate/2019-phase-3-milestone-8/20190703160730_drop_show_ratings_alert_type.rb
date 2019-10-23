class DropShowRatingsAlertType < ActiveRecord::Migration[6.0]
  def change
    remove_column(:alert_types, :show_ratings, :boolean)
  end
end
