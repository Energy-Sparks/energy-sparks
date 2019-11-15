class CreateBenchmarkResultGenerationRun < ActiveRecord::Migration[6.0]
  def change
    create_table :benchmark_result_generation_runs do |t|
      t.references :school, null: false, foreign_key: { on_delete: :cascade }
      t.timestamps
    end
  end
end

