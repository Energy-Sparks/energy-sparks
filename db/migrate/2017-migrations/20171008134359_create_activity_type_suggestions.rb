class CreateActivityTypeSuggestions < ActiveRecord::Migration[5.0]
  def change
    create_table :activity_type_suggestions do |t|
      t.references :activity_type, index: true, foreign_key: true
      t.integer :suggested_type_id
      t.timestamps
    end
    # add_foreign_key :activity_type_suggestions, :activity_types, column: :suggested_activity_type_id
    # add_index :activity_type_suggestions, [:activity_type_id, :suggested_activity_type_id], unique: true, name: "activity_type_suggestion_unique"
  end
end
