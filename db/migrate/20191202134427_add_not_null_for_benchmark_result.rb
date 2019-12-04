class AddNotNullForBenchmarkResult < ActiveRecord::Migration[6.0]
  def change
    change_column_null :benchmark_results, :benchmark_result_generation_run_id, false
  end
end
