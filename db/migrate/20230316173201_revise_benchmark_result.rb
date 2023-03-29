class ReviseBenchmarkResult < ActiveRecord::Migration[6.0]
  def up
    add_column :benchmark_results, :results_cy, :json, default: {}
    remove_column :benchmark_results, :data
  end

  def down
    add_column :benchmark_results, :data, :text
    remove_column :benchmark_results, :results_cy
  end

end
