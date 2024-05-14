class CreateComparisonMetricTypes < ActiveRecord::Migration[6.1]
  def change
    create_table :comparison_metric_types do |t|
      t.string :key, null: false
      t.integer :units, null: false # enum
      t.integer :fuel_type, null: false # enum
      t.index [:key, :fuel_type], unique: true
      t.timestamps
    end
  end
end
