module Charts
  class SelectableSchoolChartsComponentPreview < ViewComponent::Preview
    def example
      schools = School.data_enabled.by_name

      safe_charts = {
        electricity: {
          baseload: {
            label: 'Baseload'
          },
          baseload_lastyear: {
            label: 'Baseload last year'
          },
          baseload_versus_benchmarks: {
            label: 'Baseload vs benchmarks'
          },
          management_dashboard_group_by_week_electricity: {
            label: 'Group by week electricity'
          },
          group_by_week_electricity_meter_breakdown_one_year: {
            label: 'Group by week electricity, meter breakdown'
          },
          daytype_breakdown_electricity_tolerant: {
            label: 'Electricity use out of hours'
          },
          electricity_by_day_of_week_tolerant: {
            label: 'Out of hours electricity use by day of week'
          }
        },
        gas: {
          management_dashboard_group_by_week_gas: {
            label: 'Group by week gas'
          },
          group_by_week_gas_meter_breakdown_one_year: {
            label: 'Group by week gas, meter breakdown'
          },
          daytype_breakdown_gas_tolerant: {
            label: 'Gas use out of hours'
          },
          gas_by_day_of_week_tolerant: {
            label: 'Out of hours gas use by day of week'
          }
        },
        solar_pv: {
          management_dashboard_group_by_month_solar_pv: {
            label: 'Solar generation and use by month'
          }
        }
      }

      fuel_types = [:electricity, :gas, :solar_pv]

      component = Charts::SelectableSchoolChartsComponent.new(schools:, fuel_types:, charts: safe_charts)
      render(component)
    end
  end
end
