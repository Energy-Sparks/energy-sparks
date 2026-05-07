# frozen_string_literal: true

class AddEnergyEfficiencyToMetricTypeEnum < ActiveRecord::Migration[8.1]
  def change
    SchoolGroups::ImpactReport::EnergyEfficiency::METRICS.each do |metric|
      add_enum_value :impact_report_metric_types, metric
    end
  end
end
