class RemoveFieldsFromSchoolTargets < ActiveRecord::Migration[7.2]
  def change
    change_table :school_targets, bulk: true do |t|
      t.remove :electricity_progress, type: :json
      t.remove :electricity_report, type: :jsonb
      t.remove :gas_progress, type: :json
      t.remove :gas_report, type: :jsonb
      t.remove :storage_heaters_progress, type: :json
      t.remove :storage_heaters_report, type: :jsonb
      t.remove :report_last_generated, type: :datetime
    end
  end
end
