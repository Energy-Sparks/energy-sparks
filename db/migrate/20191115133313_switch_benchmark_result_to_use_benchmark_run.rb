class SwitchBenchmarkResultToUseBenchmarkRun < ActiveRecord::Migration[6.0]
  def change
    add_reference :benchmark_results, :benchmark_result_generation_run, foreign_key: {on_delete: :cascade}, index: {name: 'ben_rgr_index'}
    remove_column :benchmark_results, :alert_generation_run_id
  end
end


