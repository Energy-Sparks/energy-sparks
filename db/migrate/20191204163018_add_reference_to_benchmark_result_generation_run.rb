class AddReferenceToBenchmarkResultGenerationRun < ActiveRecord::Migration[6.0]
  def change
    add_reference :benchmark_result_school_generation_runs, :benchmark_result_generation_run, foreign_key: { on_delete: :cascade }, index: {name: 'benchmark_result_school_generation_run_idx'}
  end
end
