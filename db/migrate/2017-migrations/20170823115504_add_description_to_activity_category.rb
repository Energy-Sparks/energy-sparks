class AddDescriptionToActivityCategory < ActiveRecord::Migration[5.0]
  def change
    add_column :activity_categories, :description, :string
  end
end
