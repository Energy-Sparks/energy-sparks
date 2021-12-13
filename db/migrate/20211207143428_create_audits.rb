class CreateAudits < ActiveRecord::Migration[6.0]
  def change
    create_table :audits do |t|
      t.references :school, null: false, foreign_key: {on_delete: :cascade}
      t.string :title, null: false
      t.date :completed_on
      t.boolean :published, default: false
      t.timestamps
    end
    create_join_table :audits, :activity_types, table_name: :audit_activity_types do |t|
      t.index [:audit_id, :activity_type_id], unique: true, name: 'audit_activity_type_uniq'
      t.primary_key :id
      t.integer     :position, default: 0, null: false
      t.text        :notes
    end
    create_join_table :audits, :intervention_types, table_name: :audit_intervention_types do |t|
      t.index [:audit_id, :intervention_type_id], unique: true, name: 'audit_intervention_type_uniq'
      t.primary_key :id
      t.integer     :position, default: 0, null: false
      t.text        :notes
    end
  end
end
