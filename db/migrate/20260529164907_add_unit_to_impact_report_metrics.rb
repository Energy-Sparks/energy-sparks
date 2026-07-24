# frozen_string_literal: true

class AddUnitToImpactReportMetrics < ActiveRecord::Migration[8.1]
  def change
    create_enum :impact_report_metric_units, %w[kwh co2 gbp]
    add_column :impact_report_metrics, :unit, :enum, enum_type: :impact_report_metric_units
  end
end
