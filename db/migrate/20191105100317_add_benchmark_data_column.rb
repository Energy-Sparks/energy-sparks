class AddBenchmarkDataColumn < ActiveRecord::Migration[6.0]
  def change
    add_column :alerts, :benchmark_data, :json, default: {}
  end
end
