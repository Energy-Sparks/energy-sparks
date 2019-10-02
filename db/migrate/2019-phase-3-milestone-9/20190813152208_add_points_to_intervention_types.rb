class AddPointsToInterventionTypes < ActiveRecord::Migration[6.0]
  def change
    add_column :intervention_types, :points, :integer
  end
end
