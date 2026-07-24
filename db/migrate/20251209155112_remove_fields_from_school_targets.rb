class RemoveFieldsFromSchoolTargets < ActiveRecord::Migration[7.2]
  def change
    change_table :school_targets, bulk: true do |t|
      t.remove :electricity_report, type: :jsonb, default: {}
      t.remove :gas_report, type: :jsonb, default: {}
      t.remove :storage_heaters_report, type: :jsonb, default: {}
    end
  end
end
