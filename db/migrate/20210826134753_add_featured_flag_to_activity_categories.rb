class AddFeaturedFlagToActivityCategories < ActiveRecord::Migration[6.0]
  def change
    add_column :activity_categories, :featured, :boolean, default: false
  end
end
