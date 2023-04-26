class AddProgressReportsToSchoolTarget < ActiveRecord::Migration[6.0]
  def change
    add_column :school_targets, :electricity_report, :jsonb, default: {}
    add_column :school_targets, :gas_report, :jsonb, default: {}
    add_column :school_targets, :storage_heaters_report, :jsonb, default: {}
  end
end
