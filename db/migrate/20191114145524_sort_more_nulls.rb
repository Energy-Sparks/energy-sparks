class SortMoreNulls < ActiveRecord::Migration[6.0]
  def change
    change_column_null :alert_errors, :alert_generation_run_id, false
    change_column_null :alert_errors, :alert_type_id, false
    change_column_null :benchmark_results, :alert_generation_run_id, false
    change_column_null :benchmark_results, :alert_type_id, false
    change_column_null :alert_generation_runs, :school_id, false
  end
end
