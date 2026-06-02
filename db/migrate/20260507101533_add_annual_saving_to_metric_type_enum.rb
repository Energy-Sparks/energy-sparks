# frozen_string_literal: true

class AddAnnualSavingToMetricTypeEnum < ActiveRecord::Migration[8.1]
  def up
    SchoolGroups::ImpactReport::Generator::AnnualSaving::METRICS.each do |metric|
      add_enum_value :impact_report_metric_types, metric
    end
  end

  def down = nil
end
