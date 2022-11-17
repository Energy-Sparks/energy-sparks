class RemoveNotNullConstraintFromInterventionTypeName < ActiveRecord::Migration[6.0]
  def change
    change_column_null :intervention_types, :name, true
  end
end
