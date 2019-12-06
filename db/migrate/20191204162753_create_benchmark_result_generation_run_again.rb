class CreateBenchmarkResultGenerationRunAgain < ActiveRecord::Migration[6.0]
  def change
    create_table :benchmark_result_generation_runs do |t|
      t.timestamps
    end
  end
end
