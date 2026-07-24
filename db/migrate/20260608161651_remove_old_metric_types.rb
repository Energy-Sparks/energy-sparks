# frozen_string_literal: true

class RemoveOldMetricTypes < ActiveRecord::Migration[8.1]
  def up
    create_enum :impact_report_metric_types_orig,
                %i[actions active_users activities annual_saving
                   baseload
                   data_visible_schools
                   enrolled_schools enrolling_schools
                   heating_control heating_down heating_early heating_off holiday_previous holiday_previous_year
                   insulate_pipes
                   long_term
                   out_of_hours
                   peak points pupils
                   solar_panels
                   targets
                   thermostatic_control
                   use users
                   visible_schools]
    execute 'ALTER TABLE impact_report_metrics ALTER COLUMN metric_type TYPE impact_report_metric_types_orig ' \
            'USING metric_type::text::impact_report_metric_types_orig;'
    drop_enum :impact_report_metric_types
    rename_enum :impact_report_metric_types_orig, :impact_report_metric_types
  end

  def down = nil
end
