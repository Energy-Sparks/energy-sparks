# frozen_string_literal: true

class AddUniqueIndexToImpactReportMetrics < ActiveRecord::Migration[8.1]
  def change
    add_index :impact_report_metrics,
              %i[impact_report_run_id metric_category fuel_type metric_type],
              unique: true,
              name: 'idx_impact_report_metrics_unique'
  end
end
