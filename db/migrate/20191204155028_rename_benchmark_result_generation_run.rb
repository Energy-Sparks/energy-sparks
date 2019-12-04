class RenameBenchmarkResultGenerationRun < ActiveRecord::Migration[6.0]
  def change
    rename_table :benchmark_result_generation_runs, :benchmark_result_school_generation_runs
    rename_column :benchmark_results, :benchmark_result_generation_run_id, :benchmark_result_school_generation_run_id
    rename_column :benchmark_result_errors, :benchmark_result_generation_run_id, :benchmark_result_school_generation_run_id
  end
end
