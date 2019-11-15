class SortOutNulls < ActiveRecord::Migration[6.0]
  def change
    change_column_null :benchmark_results, :asof, false
    change_column_null :alert_errors, :asof_date, false
  end
end
