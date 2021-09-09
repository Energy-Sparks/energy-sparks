class ReviseInterventionTypeGroups < ActiveRecord::Migration[6.0]
  def change
    add_column :intervention_type_groups, :description, :string
    add_column :intervention_type_groups, :active, :boolean, default: true
  end
end
