class AddHasVariablesFlagsToAlertTypes < ActiveRecord::Migration[5.2]
  def change
    add_column :alert_types, :has_variables, :boolean, default: false
  end
end
