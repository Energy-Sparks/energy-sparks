class AddJsonColumnToBenchmarkResult < ActiveRecord::Migration[6.0]
  def change
    add_column :benchmark_results, :results, :json, default: {}
  end
end
