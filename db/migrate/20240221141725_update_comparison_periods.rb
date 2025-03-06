class UpdateComparisonPeriods < ActiveRecord::Migration[6.1]
  def up
    remove_foreign_key :comparison_reports, :comparison_periods
    add_foreign_key :comparison_reports, :comparison_periods, column: 'custom_period_id'
  end

  def down
    remove_foreign_key :comparison_reports, :comparison_periods
    add_foreign_key :comparison_reports, :comparison_periods, column: 'custom_period_id', on_delete: :cascade
  end
end
