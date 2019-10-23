class AddOtherFlagToInterventionTypes < ActiveRecord::Migration[6.0]
  def change
    add_column :intervention_types, :other, :boolean, default: false
  end
end
