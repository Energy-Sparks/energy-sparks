class ChangeUniqueIndexOnAuditActivitiesAndInterventions < ActiveRecord::Migration[6.0]
  def change
    remove_index :audit_activity_types, %i[audit_id activity_type_id]
    add_index :audit_activity_types, [:audit_id], unique: false
    remove_index :audit_intervention_types, %i[audit_id intervention_type_id]
    add_index :audit_intervention_types, [:audit_id], unique: false
  end
end
