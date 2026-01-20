class DashboardConfiguration
  DASHBOARD_PAGE_GROUPS = {  # dashboard page groups: defined page, and charts on that page
    main_dashboard_electric:  {
                                name:   'Overview',
                                charts: %i[
                                  benchmark
                                  daytype_breakdown_electricity
                                  management_dashboard_group_by_week_electricity
                                ]
                              },
    main_dashboard_electric_solar:  {
                                name:   'Overview',
                                charts: %i[
                                  benchmark_kwh_electric_only
                                  daytype_breakdown_electricity
                                  management_dashboard_group_by_week_electricity
                                  solar_pv_group_by_month_dashboard_overview
                                ]
                              },
    # Benchmark currently not working for Gas only
    main_dashboard_gas:  {
                                name:   'Main Dashboard',
                                charts: %i[
                                  benchmark
                                  daytype_breakdown_gas
                                  management_dashboard_group_by_week_gas
                                ]
                              },
    electricity_detail:      {
                                name:   'Electricity Detail',
                                charts: %i[
                                  daytype_breakdown_electricity
                                  management_dashboard_group_by_week_electricity
                                  group_by_week_electricity_unlimited
                                  electricity_longterm_trend
                                  electricity_by_day_of_week
                                  baseload
                                  electricity_by_month_year_0_1
                                  intraday_line_school_days_reduced_data
                                  intraday_line_holidays
                                  intraday_line_weekends
                                  intraday_line_school_days_last5weeks
                                  intraday_line_school_days_6months
                                  intraday_line_school_last7days
                                  baseload_lastyear
                                ]
                              },
    gas_detail:               {
                                name:   'Gas Detail',
                                charts: %i[
                                  daytype_breakdown_gas
                                  management_dashboard_group_by_week_gas
                                  group_by_week_gas_unlimited
                                  gas_longterm_trend
                                  gas_by_day_of_week
                                  gas_heating_season_intraday
                                  last_2_weeks_gas
                                  last_2_weeks_gas_degreedays
                                  last_2_weeks_gas_comparison_temperature_compensated
                                  last_4_weeks_gas_temperature_compensated
                                  last_7_days_intraday_gas
                                ]
                              },
    pupil_analysis_page: {
      name:   'Pupil Analysis',
      sub_pages:  [
        {
          name:     'Electricity',
          sub_pages:  [
            { name: 'kWh',    charts: %i[pupil_dashboard_group_by_week_electricity_kwh] },
            { name: 'Cost',   charts: %i[pupil_dashboard_group_by_week_electricity_£] },
            { name: 'CO2',    charts: %i[pupil_dashboard_group_by_week_electricity_co2] },
            { name: 'Pie',    charts: %i[pupil_dashboard_daytype_breakdown_electricity] },
            {
              name: 'Bar',
              sub_pages: [
                { name: 'Bench',   charts: %i[pupil_dashboard_electricity_benchmark] },
                { name: 'Week',    charts: %i[pupil_dashboard_group_by_week_electricity_£] },
                { name: 'Year',    charts: %i[pupil_dashboard_electricity_longterm_trend_£] }
              ]
            },
            {
              name: 'Line',
              sub_pages: [
                { name: 'Base',   charts: %i[pupil_dashboard_baseload_lastyear] },
                { name: '7days',  charts: %i[pupil_dashboard_intraday_line_electricity_last7days] }
              ]
            }
          ],
        },
        {
          name:     'Gas',
          sub_pages:  [
            { name: 'kWh',    charts: %i[pupil_dashboard_group_by_week_gas_kwh] },
            { name: 'Cost',   charts: %i[pupil_dashboard_group_by_week_gas_£] },
            { name: 'CO2',    charts: %i[pupil_dashboard_group_by_week_gas_co2] },
            { name: 'Pie',    charts: %i[pupil_dashboard_daytype_breakdown_gas] },
            {
              name: 'Bar',
              sub_pages: [
                { name: 'Bench',   charts: %i[pupil_dashboard_gas_benchmark] },
                { name: 'Week',    charts: %i[pupil_dashboard_group_by_week_gas_£] },
                { name: 'Year',    charts: %i[pupil_dashboard_gas_longterm_trend_£] }
              ]
            },
            { name: 'Line',  charts: %i[pupil_dashboard_intraday_line_gas_last7days] }
          ],
        },
        {
          name:     'Storage Heaters',
          sub_pages:  [
            { name: 'kWh',    charts: %i[pupil_dashboard_group_by_week_storage_heaters_kwh] },
            { name: 'Cost',   charts: %i[pupil_dashboard_group_by_week_storage_heaters_£] },
            { name: 'CO2',    charts: %i[pupil_dashboard_group_by_week_storage_heaters_co2] },
            { name: 'Pie',    charts: %i[pupil_dashboard_daytype_breakdown_storage_heaters] },
            {
              name: 'Bar',
              sub_pages: [
                { name: 'Bench',   charts: %i[pupil_dashboard_storage_heaters_benchmark] },
                { name: 'Week',    charts: %i[pupil_dashboard_group_by_week_storage_heaters_£] },
                { name: 'Year',    charts: %i[pupil_dashboard_storage_heaters_longterm_trend_£] }
              ]
            },
            { name: 'Line',  charts: %i[pupil_dashboard_intraday_line_storage_heaters_last7days] },
          ],
        },
        {
          name:     'Electricity+Solar PV',
          sub_pages:  [
            { name: 'kWh',    charts: %i[pupil_dashboard_group_by_week_electricity_kwh] },
            { name: 'Solar',  charts: %i[pupil_dashboard_solar_pv_monthly] },
            { name: 'Pie',    charts: %i[pupil_dashboard_daytype_breakdown_electricity] },
            {
              name: 'Bar',
              sub_pages: [
                { name: 'Bench',   charts: %i[pupil_dashboard_solar_pv_benchmark] },
                { name: 'Week',    charts: %i[pupil_dashboard_group_by_week_electricity_£] },
                { name: 'Year',    charts: %i[pupil_dashboard_electricity_longterm_trend_£] }
              ]
            },
            {
              name: 'Line',
              sub_pages: [
                { name: 'Base',   charts: %i[pupil_dashboard_baseload_lastyear] },
                { name: '7days',  charts: %i[pupil_dashboard_intraday_line_electricity_last7days] }
              ]
            }
          ],
        }
      ],
    },
#======================================================================================================
    main_dashboard_electric_and_gas: {
                                name:   'Overview',
                                charts: %i[
                                  benchmark
                                  daytype_breakdown_electricity
                                  daytype_breakdown_gas
                                  management_dashboard_group_by_week_electricity
                                  management_dashboard_group_by_week_gas
                                ]
                              },
    main_dashboard_electric_and_gas_and_solar: {
                                name:   'Overview',
                                charts: %i[
                                  benchmark_kwh
                                  daytype_breakdown_electricity
                                  daytype_breakdown_gas
                                  management_dashboard_group_by_week_electricity
                                  management_dashboard_group_by_week_gas
                                  solar_pv_group_by_month_dashboard_overview
                                ]
                              },
    boiler_control:           {
                                name: 'Advanced Boiler Control',
                                charts: %i[
                                  management_dashboard_group_by_week_gas
                                  frost_1
                                  frost_2
                                  frost_3
                                  thermostatic
                                  cusum
                                  thermostatic_control_large_diurnal_range_1
                                  thermostatic_control_large_diurnal_range_2
                                  thermostatic_control_large_diurnal_range_3
                                  thermostatic_control_medium_diurnal_range
                                  optimum_start
                                  hotwater
                                  heating_on_off_by_week
                                ]
                              },
        test:                 {
                                name: 'Useful Charts for Testing',
                                charts: %i[
                                  electricity_by_month_year_0_1
                                  group_by_week_gas_meter_breakdown
                                  group_by_week_electricity_meter_breakdown
                                  electricity_longterm_trend
                                  gas_longterm_trend
                                  irradiance_test
                                  gridcarbon_test
                                  cusum_weekly
                                ]
                              },
        heating_model_fitting: {
                                name: 'Heating Model Fitting',
                                change_measurement_units:   false,
                                charts: %i[
                                  group_by_week_gas_model_fitting_one_year
                                  group_by_week_gas_model_fitting_unlimited
                                  gas_by_day_of_week_model_fitting
                                  gas_longterm_trend_model_fitting
                                  thermostatic_regression_simple_school_day_non_heating_regression_covid_tolerant
                                  seasonal_simple_school_day_non_heating_regression_covid_tolerant
                                  thermostatic_regression_simple_school_day_non_heating_regression
                                  seasonal_simple_school_day_non_heating_regression
                                  thermostatic_regression_simple_school_day_non_heating_non_regression
                                  seasonal_simple_school_day_non_heating_non_regression
                                  thermostatic_regression_simple_school_day
                                  thermostatic_regression_simple_all
                                  thermostatic_regression_thermally_massive_school_day
                                  thermostatic_regression_thermally_massive_all
                                  cusum_weekly_best_model
                                  thermostatic_winter_holiday_best
                                  thermostatic_winter_weekend_best
                                  thermostatic_summer_school_day_holiday_best
                                  thermostatic_summer_weekend_best
                                  thermostatic_non_best
                                  cusum_simple
                                  cusum_thermal_mass
                                  heating_on_off_by_week
                                  thermostatic_model_categories_pie_chart
                                  heating_on_off_pie_chart
                                ],
                               },
        storage_heaters:      {
                                  name: 'Storage Heaters',
                                  charts: %i[
                                    management_dashboard_group_by_week_storage_heater
                                    storage_heater_group_by_week_long_term
                                    storage_heater_by_day_of_week
                                    storage_heater_intraday_current_year
                                    storage_heater_intraday_current_year_kw
                                    intraday_line_school_last7days_storage_heaters
                                    heating_on_off_by_week_storage_heater
                                    storage_heater_thermostatic
                                  ],
                              },
        solar_pv:             {
                                name: 'Solar PV',
                                change_measurement_units:   false,
                                charts: %i[
                                  management_dashboard_group_by_month_solar_pv
                                  solar_pv_last_7_days_by_submeter
                                ],
                              },
        carbon_emissions:   {
                                name: 'Carbon Emissions',
                                change_measurement_units:   false,
                                charts: %i[
                                  benchmark_co2
                                  electricity_longterm_trend_kwh_with_carbon
                                  electricity_longterm_trend_carbon
                                  electricity_co2_last_year_weekly_with_co2_intensity_co2_only
                                  electricity_co2_last_7_days_with_co2_intensity
                                  electricity_kwh_last_7_days_with_co2_intensity
                                  gas_longterm_trend_kwh_with_carbon
                                  group_by_week_carbon
                                ],
                              },
        cost:   {
                                name: 'Costs',
                                change_measurement_units:   false,
                                charts: %i[
                                  electricity_by_month_year_0_1_finance_advice
                                  electricity_cost_comparison_last_2_years_accounting
                                  electricity_cost_1_year_accounting_breakdown
                                  accounting_cost_daytype_breakdown_electricity

                                  gas_by_month_year_0_1_finance_advice
                                  gas_cost_comparison_last_2_years_accounting
                                  gas_cost_1_year_accounting_breakdown
                                  accounting_cost_daytype_breakdown_gas
                                ],
                              },
        cost_electricity_only:   {
                                name: 'Costs',
                                change_measurement_units:   false,
                                charts: %i[
                                  electricity_by_month_year_0_1_finance_advice
                                  electricity_cost_comparison_last_2_years_accounting
                                  electricity_cost_1_year_accounting_breakdown
                                  accounting_cost_daytype_breakdown_electricity
                                ],
                              },
        cost_unused: {
                              name: 'Cost - additional',
                              charts: %i[
                                electricity_cost_comparison_last_2_years
                                electricity_cost_comparison_last_2_years_accounting_breakdown
                                gas_1_year_intraday_accounting_breakdown
                                electricity_cost_comparison_1_year_accounting_breakdown_by_week
                                gas_cost_comparison_1_year_accounting_breakdown_by_week
                                gas_cost_comparison_1_year_economic_breakdown_by_week
                                electricity_2_week_accounting_breakdown
                                electricity_1_year_intraday_accounting_breakdown
                                electricity_1_year_intraday_kwh_breakdown
                                gas_1_year_intraday_accounting_breakdown
                                gas_1_year_intraday_economic_breakdown
                                gas_1_year_intraday_kwh_breakdown
                                electricity_cost_comparison_last_2_years
                                electricity_cost_comparison_last_2_years_accounting_breakdown
                              ],
                              },
}.freeze
end
