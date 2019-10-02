class RenameAlertTypeCategoryToFuelType < ActiveRecord::Migration[5.2]
  def change
    rename_column(:alert_types, :category, :fuel_type)
  end
end
