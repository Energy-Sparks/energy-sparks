# frozen_string_literal: true

class AddPotentialSavingsToMetricTypeEnum < ActiveRecord::Migration[8.1]
  def change
    SchoolGroups::ImpactReport::PotentialSavings::METRICS.each do |metric|
      add_enum_value :impact_report_metric_types, metric
    end
  end
end
