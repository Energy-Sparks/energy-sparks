class AddInterventionTypesAndGroups < ActiveRecord::Migration[6.0]
  def change
    create_table :intervention_type_groups do |t|
      t.string :title, null: false, unique: true
      t.timestamps
    end
    create_table :intervention_types do |t|
      t.string :title, null: false, unique: true
      t.references :intervention_type_group, null: false, foreign_key: {on_delete: :cascade}
    end

    add_reference :observations, :intervention_type, foreign_key: {on_delete: :restrict}
  end
end
