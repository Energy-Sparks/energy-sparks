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

    create_enum :impact_report_metric_categories,
                %w[overview energy_efficiency engagement potential_savings footnotes]
    create_enum :impact_report_metric_types,
                %w[visible_schools data_visible_schools users active_users pupils enrolled_schools enrolling_schools] +
                %w[activities actions points targets] +
                %w[total_savings]

    create_table :impact_report_metrics do |t|
      t.references :impact_report_run, null: false, foreign_key: true
      t.integer :number_of_schools, null: true
      t.boolean :enough_data, default: false, null: false
      t.integer :fuel_type, null: true
      t.integer :value, null: false
      t.enum :metric_category, enum_type: :impact_report_metric_categories, null: false
      t.enum :metric_type, enum_type: :impact_report_metric_types, null: false
      t.timestamps
    end
  end
end
