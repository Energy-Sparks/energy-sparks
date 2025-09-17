module SchoolGroups
  class Charts
    # Set of "safe" charts that should work across all (or the majority of schools) with
    # the specified fuel type regardless of the amount of data available.
    #
    # This could later be merged with the ChartManager::STANDARD_CHART_CONFIGURATION class but the
    # content there needs tidying first.
    SAFE_CHARTS = {
      electricity: {
        management_dashboard_group_by_week_electricity: {
          advice_page: :electricity_long_term
        },
        group_by_week_electricity_meter_breakdown_one_year: {
          advice_page: :electricity_meter_breakdown
        },
        baseload_lastyear: {
          advice_page: :baseload
        },
        baseload: {
          advice_page: :baseload
        },
        baseload_versus_benchmarks: {
          advice_page: :baseload
        },
        daytype_breakdown_electricity_tolerant: {
          advice_page: :electricity_out_of_hours
        },
        electricity_by_day_of_week_tolerant: {
          advice_page: :electricity_out_of_hours
        }
      },
      gas: {
        management_dashboard_group_by_week_gas: {
          advice_page: :gas_long_term
        },
        group_by_week_gas_meter_breakdown_one_year: {
          advice_page: :gas_meter_breakdown
        },
        daytype_breakdown_gas_tolerant: {
          advice_page: :gas_out_of_hours
        },
        gas_by_day_of_week_tolerant: {
          advice_page: :gas_out_of_hours
        }
      },
      solar_pv: {
        management_dashboard_group_by_month_solar_pv: {
          advice_page: :solar_pv
        }
      },
      storage_heaters: {
        storage_heater_group_by_week: {
          advice_page: :storage_heaters
        },
        storage_heater_by_day_of_week_tolerant: {
          advice_page: :storage_heaters
        }
      }
    }.freeze

    # Rework the above to include the translated labels, titles and subtitles
    #
    # Note: the subtitles support substitution of school name using {{name}}.
    # The substitution is done using Handlebars in JS, hence different syntax.
    def safe_charts
      SAFE_CHARTS.map do |fuel_type, charts|
        updated_charts = charts.map do |chart_type, config|
          scope = "school_groups.advice.chart_types.#{fuel_type}"
          update_config = config.merge({
            label: I18n.t("#{chart_type}.label", scope:, default: nil),
            title: I18n.t("#{chart_type}.title", scope:, default: nil),
            subtitle: I18n.t("#{chart_type}.subtitle", scope:, default: nil),
          })
          [chart_type, update_config.compact]
        end.to_h
        [fuel_type, updated_charts]
      end.to_h
    end
  end
end
