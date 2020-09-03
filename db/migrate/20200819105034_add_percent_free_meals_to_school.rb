class AddPercentFreeMealsToSchool < ActiveRecord::Migration[6.0]
  def change
    add_column :schools, :percentage_free_school_meals, :integer
  end
end
