class AddIndicesForComparisons < ActiveRecord::Migration[7.1]
  def change
    add_index :alert_generation_runs, [:school_id, :created_at], order: { created_at: :desc }
    add_index :alert_types, :class_name
  end
end
