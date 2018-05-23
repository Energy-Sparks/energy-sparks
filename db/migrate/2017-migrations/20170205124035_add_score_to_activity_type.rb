class AddScoreToActivityType < ActiveRecord::Migration[5.0]
  def change
    add_column :activity_types, :score, :integer
  end
end
