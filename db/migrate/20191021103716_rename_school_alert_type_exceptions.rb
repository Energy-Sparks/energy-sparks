class RenameSchoolAlertTypeExclusions < ActiveRecord::Migration[6.0]
  def change
    rename_table :school_alert_type_exceptions, :school_alert_type_exclusions
  end
end
