class AddDisabledToComparisonReports < ActiveRecord::Migration[6.1]
  def change
    add_column :comparison_reports, :disabled, :boolean, null: false, default: false
  end
end
