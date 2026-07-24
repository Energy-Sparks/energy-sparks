# frozen_string_literal: true

class AddWithNoUnitToMetricTypeEnum < ActiveRecord::Migration[8.1]
  def up
    %i[annual_saving holiday_previous holiday_previous_year].each do |metric|
      add_enum_value :impact_report_metric_types, metric
    end
  end

  def down = nil
end
