class AddIconToInterventionTypeGroup < ActiveRecord::Migration[6.0]
  def change
    add_column :intervention_type_groups, :icon, :string, default: 'question-circle'
  end
end
