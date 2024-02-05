class CreateMetricTypes < ActiveRecord::Migration[6.1]
  def change
    create_table :metric_types do |t|
      t.string :key, null: false, unique: true
      t.string :label
      t.string :description
      t.integer :type # enum
      t.integer :fuel_type # enum
      t.timestamps
    end
  end
end
