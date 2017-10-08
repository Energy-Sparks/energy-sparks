class AddDataDrivenToActivityType < ActiveRecord::Migration[5.0]
  def change
    add_column :activity_types, :data_driven, :boolean, default: false
  end
end
