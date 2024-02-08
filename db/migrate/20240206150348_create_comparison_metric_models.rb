class CreateComparisonMetricModels < ActiveRecord::Migration[6.1]
  def change
    create_table :comparison_periods do |t|
      t.string :current_label, null: false
      t.date :current_start_date, null: false
      t.date :current_end_date, null: false
      t.string :previous_label, null: false
      t.date :previous_start_date, null: false
      t.date :previous_end_date, null: false
      t.timestamps
    end

    create_table :comparison_metrics do |t|
      t.references :school, null: false, foreign_key: { on_delete: :cascade }
      t.references :metric_type, null: false, foreign_key: { to_table: 'comparison_metrics', on_delete: :cascade }
      t.references :alert_type, null: false
      t.string :value
      t.integer :reporting_period # enum
      t.references :custom_period, foreign_key: { to_table: 'comparison_periods', on_delete: :cascade }

      t.boolean :enough_data, default: false
      t.boolean :whole_period, default: false
      t.boolean :recent_data, default: false
      t.date :asof_date

      t.timestamps
    end

    # Jumped a bit ahead here

    create_table :comparison_reports do |t|
      t.string :key, null: false, unique: true
      ## translated: title, null: false
      ## rich text: introduction
      ## rich text: notes

      t.boolean :public, default: false
      t.integer :reporting_period # enum
      t.references :custom_period, foreign_key: { to_table: 'comparison_periods', on_delete: :cascade }
      t.timestamps
    end
  end
end
