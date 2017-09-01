class AddBadgeNameToActivityType < ActiveRecord::Migration[5.0]
  def change
    add_column :activity_types, :badge_name, :string
  end
end
