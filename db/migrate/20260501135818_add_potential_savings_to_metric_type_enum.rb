# frozen_string_literal: true

class AddPotentialSavingsToMetricTypeEnum < ActiveRecord::Migration[8.1]
  def up
    %i[baseload
       out_of_hours
       peak
       use
       heating_down
       heating_early
       heating_off
       insulate_pipes
       out_of_hours
       thermostatic_control
       use
       solar_panels
       heating_off].product(%i[gbp co2 kwh]).uniq.each do |metric, type|
      add_enum_value :impact_report_metric_types, [metric, type].join('_')
    end
  end

  def down
    create_enum :impact_report_metric_types_orig,
                %w[visible_schools data_visible_schools users active_users pupils enrolled_schools enrolling_schools] +
                %w[activities actions points targets] +
                %w[total_savings]
    execute 'ALTER TABLE impact_report_metrics ALTER COLUMN metric_type TYPE impact_report_metric_types_orig ' \
            'USING metric_type::text::impact_report_metric_types_orig;'
    drop_enum :impact_report_metric_types
    rename_enum :impact_report_metric_types_orig, :impact_report_metric_types
  end
end
