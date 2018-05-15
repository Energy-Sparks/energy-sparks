class AddActivityCategoryToActivityType < ActiveRecord::Migration[5.0]
  def change
    add_reference :activity_types, :activity_category, foreign_key: true
  end
end
