class ChangeInterventionTypeGroupAttributesToMatchActivityCategory < ActiveRecord::Migration[6.0]
  def up
    rename_column :intervention_type_groups, :title, :name
    change_column_null :intervention_type_groups, :name, true
  end

  def down
    rename_column :intervention_type_groups, :name, :title
    change_column_null :intervention_type_groups, :title, false
  end
end
