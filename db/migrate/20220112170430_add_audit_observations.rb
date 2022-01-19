class AddAuditObservations < ActiveRecord::Migration[6.0]
  def change
    add_reference :observations, :audit
    add_foreign_key :observations, :audits
  end
end
