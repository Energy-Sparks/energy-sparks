class AddBadgeNameToActivityCategory < ActiveRecord::Migration[5.0]
  def change
    add_column :activity_categories, :badge_name, :string
  end
end
