class ChangeInterventionTypeAttributesToMatchActivityType < ActiveRecord::Migration[6.0]
  def change
    rename_column :intervention_types, :title, :name
    rename_column :intervention_types, :points, :score
    rename_column :intervention_types, :other, :custom
  end
end
