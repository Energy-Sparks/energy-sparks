# frozen_string_literal: true

class AddHolidayToMetricTypeEnum < ActiveRecord::Migration[8.1]
  def up
    SchoolGroups::ImpactReport::Generator::Holiday::METRICS.each do |metric|
      add_enum_value :impact_report_metric_types, metric
    end
  end

  def down = nil
end
