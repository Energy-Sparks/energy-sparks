class AddRatingsFlagToAlertType < ActiveRecord::Migration[6.0]
  def change
    add_column :alert_types, :has_ratings, :boolean, default: true
  end
end
