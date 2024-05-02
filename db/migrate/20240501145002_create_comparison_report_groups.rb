class CreateComparisonReportGroups < ActiveRecord::Migration[6.1]
  def change
    create_table :comparison_report_groups do |t|
      t.integer :position, default: 0, null: false
      t.timestamps
    end

    add_reference :comparison_reports, :comparison_report_groups, foreign_key: :report_group_id, foreign_key: true
  end
end
