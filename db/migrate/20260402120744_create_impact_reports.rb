# frozen_string_literal: true

class CreateImpactReports < ActiveRecord::Migration[7.2]
  def change # rubocop:disable Metrics/AbcSize
    create_table :impact_report_configurations do |t|
      t.references :school_group, null: false, foreign_key: true
      t.boolean :show_engagement, default: true, null: false
      t.timestamps
    end

    create_table :impact_report_runs do |t|
      t.references :school_group, null: false, foreign_key: true
      t.date :run_date, null: false
      t.timestamps
    end

    create_table :impact_report_metrics do |t|
      t.references :impact_report_run, null: false, foreign_key: true
      t.integer :number_of_schools
      t.boolean :enough_data, default: false, null: false
      t.integer :fuel_type
      t.jsonb :value, default: {}
      t.integer :metric_category, null: false
      t.integer :metric_type, null: false
      t.timestamps
    end
  end
end
