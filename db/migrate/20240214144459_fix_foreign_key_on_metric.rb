class FixForeignKeyOnMetric < ActiveRecord::Migration[6.1]
  def up
    remove_foreign_key "comparison_metrics", "comparison_metrics", column: "metric_type_id"
    add_foreign_key "comparison_metrics", "comparison_metric_types", column: "metric_type_id", on_delete: :cascade
  end

  def down
    remove_foreign_key "comparison_metrics", "comparison_metric_types", column: "metric_type_id"
    add_foreign_key "comparison_metrics", "comparison_metrics", column: "metric_type_id", on_delete: :cascade
  end

end
