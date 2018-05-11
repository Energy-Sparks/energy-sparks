class AddCustomToActivityType < ActiveRecord::Migration[5.0]
  def change
    add_column :activity_types, :custom, :boolean, default: false
  end
end
