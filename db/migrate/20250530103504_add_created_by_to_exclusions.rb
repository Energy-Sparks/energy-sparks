class AddCreatedByToExclusions < ActiveRecord::Migration[7.2]
  def change
    add_reference :school_alert_type_exclusions, :created_by, foreign_key: { to_table: :users }
  end
end
