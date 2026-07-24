# frozen_string_literal: true

class AddMoreBenchmarkMetricTypeEnum < ActiveRecord::Migration[8.1]
  def up
    SchoolGroups::ImpactReport::Generator::Benchmark::METRICS.each do |metric|
      add_enum_value :impact_report_metric_types, metric
    end
  end

  def down = nil
end
