# frozen_string_literal: true

class UpdateUniqueIndexOnImpactReportMetrics < ActiveRecord::Migration[8.1]
  def up
    remove_index :impact_report_metrics,
                 name: 'idx_impact_report_metrics_unique'

    add_index :impact_report_metrics,
              %i[impact_report_run_id metric_category fuel_type metric_type unit],
              unique: true,
              name: 'index_impact_report_metrics_unique'
  end
end
