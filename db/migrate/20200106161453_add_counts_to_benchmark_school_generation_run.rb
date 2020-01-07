class AddCountsToBenchmarkSchoolGenerationRun < ActiveRecord::Migration[6.0]
  def change
    add_column :benchmark_result_school_generation_runs, :benchmark_result_error_count, :integer, default: 0
    add_column :benchmark_result_school_generation_runs, :benchmark_result_count, :integer, default: 0
  end
end
