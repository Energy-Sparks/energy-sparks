class AddLiveDataFlagToActivityCategories < ActiveRecord::Migration[6.0]
  def change
    add_column :activity_categories, :live_data, :boolean, default: false
  end
end
