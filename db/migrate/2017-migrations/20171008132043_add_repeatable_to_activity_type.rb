class AddRepeatableToActivityType < ActiveRecord::Migration[5.0]
  def change
    add_column :activity_types, :repeatable, :boolean, default: true
  end
end
