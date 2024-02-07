class CreateComparisonMetricModels < ActiveRecord::Migration[6.1]
  def change
    create_table :comparison_periods do |t|
      t.string :label, null: false
      t.date :start_date, null: false
      t.date :end_date, null: false

      t.timestamps
    end

    create_table :comparison_metrics do |t|
      t.references :school, null: false, foreign_key: { on_delete: :cascade }
      t.references :comparison_metric_type, null: false, foreign_key: { on_delete: :cascade }
      t.references :alert_type, null: false

      t.string :value # type can vary, how do we do this?????

      # t.integer :reporting_period # enum
      # thought this would allow for more flexibility? It would allow us to present
      # exactly what is meant by last_12_months, financial_year, academic_year
      t.references :current_period, null: false, foreign_key: { to_table: 'comparison_periods', on_delete: :cascade }

      # if we had a reporting period table as used above, this could mean the comparison period below,
      # could be a reference to another reporting period. Could also be called 'previous_period'
      t.references :previous_period, foreign_key: { to_table: 'comparison_periods', on_delete: :cascade }
      ### does this reporting period information need to be stored for every metric? If it is stored for every report?

      t.boolean :enough_data, null: false
      t.boolean :whole_period, null: false
      t.boolean :recent_data, null: false
      t.date :asof_date

      t.timestamps
    end

    # create_table :comparison_periods do |t|
    #   t.current_period_start_date :date
    #    t.current_period_end_date :date
    #    t.previous_period_start_date :date
    #    t.previous_period_end_date :date
    #    t.current_period_label :string
    #    t.previous_period_label :string
    #    t.timestamps
    #  end

    create_table :comparison_reports do |t|
      t.string :key, null: false, unique: true
      t.string :title, null: false
      ## rich text: introduction
      ## rich text: notes

      t.boolean :public, default: false
      t.integer :reporting_period # enum
      # for custom reports
      t.references :custom_current_period, null: false, foreign_key: { to_table: 'comparison_periods', on_delete: :cascade }
      t.references :custom_previous_period, foreign_key: { to_table: 'comparison_periods', on_delete: :cascade }
      t.timestamps
    end

    # How do we tie metrics to reports?
    # This model assumes generated metrics can be shared across multiple reports
    create_table :comparison_run_report_metrics do |t|
      t.references :comparison_run, null: false
      t.references :comparison_report, null: false
      t.references :comparison_metric, null: false

      t.timestamps
    end

    # do we need something to tie things together?
    create_table :comparison_run do |t|
      t.date :run_on # do we only need one run a day?
      t.timestamps
    end
  end
end
