class AddFuelTypeToReport < ActiveRecord::Migration[7.2]
  def change
    add_column :comparison_reports, :fuel_type, :integer, null: true
  end
end
