class AddDescriptionConstraintToAlertType < ActiveRecord::Migration[5.2]
  def change
    change_column_null :alert_types, :description, false
  end
end
