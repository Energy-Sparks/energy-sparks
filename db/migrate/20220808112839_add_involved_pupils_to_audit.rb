class AddInvolvedPupilsToAudit < ActiveRecord::Migration[6.0]
  def change
    add_column :audits, :involved_pupils, :boolean, null: false, default: false
  end
end
