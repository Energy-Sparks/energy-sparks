class AddPupilFlagToActivityCategories < ActiveRecord::Migration[6.0]
  def change
    add_column :activity_categories, :pupil, :boolean, default: false
  end
end
