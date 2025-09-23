module Charts
  class SelectableSchoolChartsComponentPreview < ViewComponent::Preview
    # @param fuel_type select { choices: [all, electricity, gas, solar_pv] }
    # @param slug select :group_options
    def example(slug: nil, fuel_type: :all)
      fuel_types = fuel_type == :all ? [:electricity, :gas, :solar_pv] : [fuel_type]
      schools = slug ? SchoolGroup.find(slug).schools.data_enabled.by_name : School.data_enabled.by_name

      safe_charts = {
        electricity: {
          baseload: {
            label: 'Historical Baseload',
            title: 'Historical electricity baseload',
            subtitle: 'This chart shows the electricity baseload for {{name}} using all available data.',
            advice_page: :baseload
          },
          baseload_lastyear: {
            label: 'Baseload for last year',
            title: 'Electricity baseload for the last 12 months',
            subtitle: 'This chart shows the electricity baseload for {{name}} using the most recent year of data.',
            advice_page: :baseload
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

      component = Charts::SelectableSchoolChartsComponent.new(schools:, fuel_types:, charts: safe_charts)
      render(component)
    end

    private

    def group_options
      {
        choices: SchoolGroup.with_active_schools.by_name.map { |g| [g.name, g.slug] }
      }
    end
  end
end
