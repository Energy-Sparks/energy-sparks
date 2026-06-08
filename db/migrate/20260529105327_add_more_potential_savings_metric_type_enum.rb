# frozen_string_literal: true

class AddMorePotentialSavingsMetricTypeEnum < ActiveRecord::Migration[8.1]
  def up
    %i[peak use heating_down heating_early heating_off insulate_pipes thermostatic_control solar_panels]
      .each do |metric|
      add_enum_value :impact_report_metric_types, metric
    end
  end

  def down = nil
end
