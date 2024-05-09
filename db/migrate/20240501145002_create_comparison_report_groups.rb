class CreateComparisonReportGroups < ActiveRecord::Migration[6.1]
  def change
    create_table :comparison_report_groups do |t|
      t.integer :position, default: 0, null: false
      t.timestamps
    end

    add_reference :comparison_reports, :report_group, null: true, foreign_key: { to_table: :comparison_report_groups }
  end
end
