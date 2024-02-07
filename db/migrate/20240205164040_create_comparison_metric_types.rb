class CreateComparisonMetricTypes < ActiveRecord::Migration[6.1]
  def change
    create_table :comparison_metric_types do |t|
      t.string :key, null: false, unique: true
      t.string :label, null: false
      t.string :description
      t.integer :units, null: false # enum
      t.integer :fuel_type, null: false # enum
      t.timestamps
    end
  end
end
