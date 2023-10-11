class CreateInterventionTypeSuggestions < ActiveRecord::Migration[6.0]
  def change
    create_table :intervention_type_suggestions do |t|
      t.references :intervention_type, index: true, foreign_key: { on_delete: :cascade }
      t.integer :suggested_type_id, index: true
      t.timestamps
    end
  end
end
