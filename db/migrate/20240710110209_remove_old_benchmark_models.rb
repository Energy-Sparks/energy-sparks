class RemoveOldBenchmarkModels < ActiveRecord::Migration[7.1]
  def change
    drop_table :benchmark_results do |t|
      t.integer     :benchmark_result_school_generation_run_id, null: false
      t.references  :alert_type, null: false
      t.date        :asof, null: false
      t.json        :results
      t.json        :results_cy
      t.timestamps
    end
    drop_table :benchmark_result_errors do |t|
      t.references :alert_type
      t.date       :asof
      t.integer    :benchmark_result_school_generation_run_id, null: false
      t.text       :information
      t.timestamps
    end
    drop_table :benchmark_result_school_generation_runs do |t|
      t.integer   :benchmark_result_count, default: 0
      t.integer   :benchmark_result_error_count, default: 0
      t.integer   :benchmark_result_generation_run_id
      t.references :school
      t.timestamps
    end
    drop_table :benchmark_result_generation_runs do |t|
      t.timestamps
    end
  end
end
