module SchoolGroups
  class Charts
    # Set of "safe" charts that should work across all (or the majority of schools) with
    # the specified fuel type regardless of the amount of data available.
    #
    # This could later be merged with the ChartManager::STANDARD_CHART_CONFIGURATION class but the
    # content there needs tidying first.
    #
    # Note: the subtitles support substitution of school name using {{name}}.
    SAFE_CHARTS = {
      electricity: {
        management_dashboard_group_by_week_electricity: {
          label: 'Electricity use by week',
          title: 'Electricity consumption by week',
          subtitle: 'This chart gives the breakdown of electricity consumption between school day open and closed, holidays and weekends for each week for {{name}}',
          advice_page: :electricity_long_term
        },
        group_by_week_electricity_meter_breakdown_one_year: {
          label: 'Electricity use by meter',
          title: 'Electricity consumption by meter',
          subtitle: 'This chart gives the weekly breakdown of electricity consumption by meter for {{name}}',
          advice_page: :electricity_meter_breakdown
        },
        baseload_lastyear: {
          label: 'Baseload',
          title: 'Electricity baseload for the last 12 months',
          subtitle: 'This chart shows the electricity baseload for {{name}} using the most recent year of data.',
          advice_page: :baseload
        },
        baseload: {
          label: 'Long term baseload',
          subtitle: 'This chart shows the long term trend in baseload for {{name}} using all available data.',
          advice_page: :baseload
        },
        baseload_versus_benchmarks: {
          label: 'Long term baseload with comparison',
          title: 'Long term baseload comparison with benchmark and exemplar schools',
          subtitle: "This chart shows the long term trend in baseload for {{name}}, and includes a comparison with 'benchmark' and 'exemplar' schools",
          advice_page: :baseload
        },
        daytype_breakdown_electricity_tolerant: {
          label: 'Out of hours electricity use',
          title: 'Electricity usage breakdown',
          subtitle: 'This chart shows a breakdown of the electricity consumption for {{name}} over the last 12 months',
          advice_page: :electricity_out_of_hours
        },
        electricity_by_day_of_week_tolerant: {
          label: 'Out of hours electricity use by day of week',
          title: 'Electricity use by day of the week',
          subtitle: 'This chart shows the total amount of electricity used by {{name}} over the last 12 months, broken down by day of the week and time of use',
          advice_page: :electricity_out_of_hours
        }
      },
      gas: {
        management_dashboard_group_by_week_gas: {
          label: 'Gas use by week',
          title: 'Gas consumption by week',
          subtitle: 'This chart gives the breakdown of Gas consumption between school day open and closed, holidays and weekends for each week for {{name}}',
          advice_page: :gas_long_term
        },
        group_by_week_gas_meter_breakdown_one_year: {
          label: 'Gas use by meter',
          title: 'Gas consumption by meter',
          subtitle: 'This chart gives the weekly breakdown of gas consumption by meter for {{name}}',
          advice_page: :gas_meter_breakdown
        },
        daytype_breakdown_gas_tolerant: {
          label: 'Out of hours gas use',
          title: 'Gas usage breakdown',
          subtitle: 'This chart shows a breakdown of the gas consumption for {{name}} over the last 12 months',
          advice_page: :gas_out_of_hours
        },
        gas_by_day_of_week_tolerant: {
          label: 'Out of hours gas use by day of week',
          title: 'Gas use by day of the week',
          subtitle: 'This chart shows the total amount of gas used by {{name}} over the last 12 months, broken down by day of the week and time of use',
          advice_page: :gas_out_of_hours
        }
      },
      solar_pv: {
        management_dashboard_group_by_month_solar_pv: {
          label: 'Solar generation and use by month',
          title: 'Electricity consumption and solar PV for the last 12 months',
          subtitle: 'The chart below shows the electricity consumption, solar energy generation and exported solar energy for {{name}} over the last 12 months. It includes an indication of how bright the sun was during each month.',
          advice_page: :solar_pv
        }
      },
      storage_heaters: {
        storage_heater_group_by_week: {
          label: 'Storage heater electricity use by week',
          title: 'Storage heater electricity consumption for the last year',
          subtitle: 'The chart below shows your storage heater electricity consumption broken down on a weekly basis between for {{name}}',
          advice_page: :storage_heaters
        },
        storage_heater_by_day_of_week_tolerant: {
          label: 'Out of hours storage heater electricity use by day of week',
          title: 'Storage heater electricity consumption by day of the week',
          subtitle: 'This chart shows the total amount of electricity used by storage heaters in {{name}} over the last 12 months, broken down into days of the week.',
          advice_page: :storage_heaters
        }
      }
    }.freeze
  end
end
