class AddBenchmarkRunToMetric < ActiveRecord::Migration[6.1]
  def change
    add_reference 'comparison_metrics', :benchmark_result_school_generation_run, index: { name: 'idx_benchmark_school_run_metrics' }
  end
end
