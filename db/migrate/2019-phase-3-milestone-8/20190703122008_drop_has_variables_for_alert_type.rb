class DropHasVariablesForAlertType < ActiveRecord::Migration[6.0]
  def change
    remove_column(:alert_types, :has_variables, :boolean)
  end
end
