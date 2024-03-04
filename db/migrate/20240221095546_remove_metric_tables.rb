class RemoveMetricTables < ActiveRecord::Migration[6.1]
  def up
    drop_table :comparison_metric_types
    drop_table :comparison_metrics
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end

end
