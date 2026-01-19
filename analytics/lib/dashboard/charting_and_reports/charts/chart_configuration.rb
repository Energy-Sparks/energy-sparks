require_relative './series_data_manager.rb'
require_relative './chart_dynamic_x_axis.rb'
require_relative '../../modelling/solar/solar_pv_panels.rb'
# Chart Manager - aggregates data for graphing - producing 'Charts'
#                - which include basic data for graphing, comments, alerts
class ChartManager
  def self.standard_series_label_substitution(type, school_type)
    [
      ["#{type}:<school_name>", school_type],
      ["#{type}:average",       'average'],
      ["#{type}:benchmark",     'benchmark'],
      ["#{type}:exemplar",      'exemplar']
    ]
  end

  STANDARD_CHART_CONFIGURATION = {
    #
    # chart config parameters:
    # name:               As appears in title of chart; passed through back to output with addition data e.g. total kWh
    # series_breakdown:   :fuel || :daytype || :heatingon - so fuel auto splits into [gas, electricity]
    #                      daytype into holidays, weekends, schools in and out of hours
    #                      heatingon - heating and non heating days
    #                     ultimately the plan is to support a list of breaddowns
    # chart1_type:        bar || column || pie || scatter - gets passed through back to output
    # chart1_subtype:     generally not present, if present 'stacked' is its most common value
    # x_axis:             grouping of data on xaxis: :intraday :day :week :dayofweek :month :year :academicyear
    # timescale:          period overwhich data aggregated - assumes tie covering all available data if missing
    # yaxis_units:        :£ etc. TODO PG,23May2018) - complete documentation
    # data_types:         an array e.g. [:metereddata, :predictedheat] - assumes :metereddata if not present
    #
    benchmark:  {
      name:             'Annual Electricity and Gas Consumption Comparison',
      chart1_type:      :bar,
      chart1_subtype:   :stacked,
      meter_definition: :all,
      x_axis:           :year,
      series_breakdown: :fuel,
      yaxis_units:      :£,
      restrict_y1_axis: [:£, :co2],
      yaxis_scaling:    :none,
      inject:           :benchmark
    },
    benchmark_one_year:  {
      name:             'Annual Electricity and Gas Consumption Comparison, Latest year',
      inherits_from:    :benchmark,
      timescale:        :year
    },
    benchmark_varying_floor_area_pupils: {
      name:             'Annual Electricity and Gas Consumption Comparison (adjusted for changes in floor area/pupil numbers)',
      scale_y_axis:     [
        { number_of_pupils: { to: :to_current_period, series_name: 'electricity' } },
        { floor_area:       { to: :to_current_period, series_name: 'gas' } },
      ],
      inherits_from:    :benchmark,
    },
    benchmark_electric_only_£_varying_floor_area_pupils: {
      name:             'Annual Electricity Consumption Comparison (adjusted for changes in floor area/pupil numbers)',
      filter:           { fuel: [ 'electricity' ] },
      restrict_y1_axis: nil,
      scale_y_axis:     [
        { number_of_pupils: { to: :to_current_period, series_name: 'electricity' } }
      ],
      inherits_from:    :benchmark,
    },
    benchmark_gas_only_£_varying_floor_area_pupils: {
      name:             'Annual Gas Consumption Comparison (adjusted for changes in floor area/pupil numbers)',
      filter:           { fuel: [ 'gas' ] },
      restrict_y1_axis: nil,
      scale_y_axis:     [
        { number_of_pupils: { to: :to_current_period, series_name: 'gas' } }
      ],
      inherits_from:    :benchmark,
    },
    benchmark_storage_heater_only_£_varying_floor_area_pupils: {
      name:             'Annual Storage Heater Consumption Comparison (adjusted for changes in floor area/pupil numbers)',
      inherits_from:    :benchmark,
      filter:           { fuel: [ 'storage heaters' ] },
      restrict_y1_axis: nil,
      scale_y_axis:     [
        { number_of_pupils: { to: :to_current_period, series_name: 'storage heaters' } }
      ],
    },
    benchmark_co2: {
      inherits_from:    :benchmark,
      name:             'School Carbon Emissions from Electricity and Gas Usage',
      restrict_y1_axis: [:co2],
      yaxis_units:      :co2
    },
    benchmark_kwh: {
      inherits_from:    :benchmark,
      yaxis_units:      :kwh
    },
    benchmark_kwh_electric_only: {
      inherits_from:    :benchmark,
      filter:           { fuel: [ 'electricity' ] },
      restrict_y1_axis: nil,
      yaxis_units:      :kwh
    },
    benchmark_electric_only_£: {
      name:             'Annual Electricity Consumption Comparison (adjusted for changes in floor area/pupil numbers)',
      inherits_from:    :benchmark,
      filter:           { fuel: [ 'electricity' ] },
      restrict_y1_axis: nil,
      yaxis_units:      :£
    },
    benchmark_electric_only_one_year_kwh: {
      inherits_from:    :benchmark,
      meter_definition: :allelectricity,
      restrict_y1_axis: nil,
      timescale:        :year,
      yaxis_units:      :kwh
    },
    benchmark_gas_only_£: {
      inherits_from:    :benchmark,
      filter:           { fuel: [ 'gas' ] },
      restrict_y1_axis: nil,
      yaxis_units:      :£
    },
    benchmark_gas_only_one_year_kwh: {
      inherits_from:    :benchmark,
      meter_definition: :allheat,
      restrict_y1_axis: nil,
      timescale:        :year,
      yaxis_units:      :kwh
    },
    benchmark_storage_heater_only_£: {
      inherits_from:    :benchmark,
      filter:           { fuel: [ 'storage heaters' ] },
      restrict_y1_axis: nil,
      yaxis_units:      :£
    },
    benchmark_storage_heater_only_one_year_kwh: {
      inherits_from:    :benchmark_storage_heater_only_£,
      timescale:        :year,
      yaxis_units:      :kwh
    },
    last_2_weeks_carbon_emissions: {
      name:             'Last 2 weeks carbon emissions at your school from electricity and gas',
      chart1_type:      :column,
      chart1_subtype:   :stacked,
      timescale:        { week: -1..0 },
      meter_definition: :all,
      x_axis:           :day,
      series_breakdown: :fuel,
      yaxis_units:      :co2,
      yaxis_scaling:    :none
    },
    benchmark_electric:  {
      name:             'Benchmark Comparison (Annual Electricity Consumption)',
      chart1_type:      :bar,
      chart1_subtype:   :stacked,
      meter_definition: :allelectricity,
      x_axis:           :year,
      series_breakdown: :fuel,
      yaxis_units:      :£,
      yaxis_scaling:    :none,
      inject:           :benchmark
      # timescale:        :year
    },
    gas_longterm_trend: {
      name:             'Gas: long term trends',
      chart1_type:      :column,
      chart1_subtype:   :stacked,
      meter_definition: :allheat,
      x_axis:           :year,
      series_breakdown: :daytype,
      yaxis_units:      :kwh,
      yaxis_scaling:    :none,
      y2_axis:          :degreedays,
      reverse_xaxis:    true
    },
    gas_longterm_trend_kwh_with_carbon: {
      name:             'Your School Gas Carbon Emissions over the last few years',
      inherits_from:    :gas_longterm_trend,
      series_breakdown: :none,
      restrict_y1_axis: [:co2],
      y2_axis:          :gascarbon
    },
    gas_longterm_trend_carbon: {
      inherits_from:    :gas_longterm_trend,
      series_breakdown: :none,
      yaxis_units:      :co2,
      y2_axis:          :gascarbon
    },
    gas_longterm_trend_academic_year: {
      inherits_from:    :gas_longterm_trend,
      x_axis:           :academicyear,
    },
    electricity_longterm_trend: {
      name:             'Electricity: long term trends',
      chart1_type:      :column,
      chart1_subtype:   :stacked,
      meter_definition: :allelectricity,
      x_axis:           :year,
      series_breakdown: :daytype,
      yaxis_units:      :kwh,
      yaxis_scaling:    :none,
      reverse_xaxis:    true
    },
    electricity_longterm_trend_kwh_with_carbon: {
      name:             'Your schools electricity consumption over the last few years',
      inherits_from:    :electricity_longterm_trend,
      series_breakdown: :none,
      y2_axis:          :gridcarbon
    },
    electricity_longterm_trend_kwh_with_carbon_unmodified: {
      inherits_from:    :electricity_longterm_trend_kwh_with_carbon,
      meter_definition: :allelectricity_unmodified
    },
    electricity_longterm_trend_carbon: {
      name:             '', # 2 of 2 charts in same section of presentation, no header wanted
      inherits_from:    :electricity_longterm_trend,
      series_breakdown: :none,
      yaxis_units:      :co2,
      y2_axis:          :gridcarbon
    },
    electricity_longterm_trend_carbon_unmodified: {
      inherits_from:    :electricity_longterm_trend_carbon,
      meter_definition: :allelectricity_unmodified
    },
    electricity_longterm_trend_academic_year: {
      inherits_from:    :electricity_longterm_trend,
      x_axis:           :academicyear,
    },
    daytype_breakdown_gas: {
      name:             'Breakdown by type of day/time: Gas',
      chart1_type:      :pie,
      meter_definition: :allheat,
      x_axis:           :nodatebuckets,
      series_breakdown: :daytype,
      yaxis_units:      :kwh,
      yaxis_scaling:    :none,
      timescale:        :year,
      subtitle:         :daterange
    },
    daytype_breakdown_gas_tolerant: {
      inherits_from:    :daytype_breakdown_gas,
      timescale:        :up_to_a_year
    },
    daytype_breakdown_combined_fuels: { # double breakdown doesn't work TODO(PH, 29Apr2019)
      inherits_from:    :daytype_breakdown_gas,
      meter_definition: :all,
      series_breakdown: %i[daytype fuel]
    },
    alert_daytype_breakdown_gas: {
      inherits_from: :daytype_breakdown_gas
    },
    alert_daytype_breakdown_gas_kwh: {
      inherits_from: :alert_daytype_breakdown_gas,
      yaxis_units:   :kwh
    },
    alert_daytype_breakdown_gas_co2: {
      inherits_from: :alert_daytype_breakdown_gas,
      yaxis_units:   :co2
    },
    alert_daytype_breakdown_gas_£: {
      inherits_from: :alert_daytype_breakdown_gas,
      yaxis_units:   :£,
    },
    alert_daytype_breakdown_gas_£current: {
      inherits_from: :alert_daytype_breakdown_gas_£,
      yaxis_units:   :£current,
    },
    alert_daytype_breakdown_storage_heater: {
      inherits_from:      :alert_daytype_breakdown_gas,
      name:               'Breakdown by type of day/time: Storage Heaters',
      replace_series_label: [[Series::DayType::SCHOOLDAYCLOSED, Series::DayType::STORAGE_HEATER_CHARGE]],
      meter_definition:   :storage_heater_meter
    },
    alert_daytype_breakdown_storage_heater_kwh: {
      inherits_from: :alert_daytype_breakdown_storage_heater,
      yaxis_units:   :kwh
    },
    alert_daytype_breakdown_storage_heater_co2: {
      inherits_from: :alert_daytype_breakdown_storage_heater,
      yaxis_units:   :co2
    },
    alert_daytype_breakdown_storage_heater_£: {
      inherits_from: :alert_daytype_breakdown_storage_heater,
      yaxis_units:   :£,
    },
    alert_daytype_breakdown_storage_heater_£current: {
      inherits_from: :alert_daytype_breakdown_storage_heater_£,
      yaxis_units:   :£current,
    },
    daytype_breakdown_electricity: {
      name:             'Breakdown by type of day/time: Electricity',
      chart1_type:      :pie,
      meter_definition: :allelectricity,
      x_axis:           :nodatebuckets,
      series_breakdown: :daytype,
      yaxis_units:      :kwh,
      yaxis_scaling:    :none,
      timescale:        :year,
      subtitle:         :daterange
    },
    daytype_breakdown_electricity_tolerant: {
      inherits_from:    :daytype_breakdown_electricity,
      timescale:        :up_to_a_year
    },
    alert_daytype_breakdown_electricity: {
      inherits_from: :daytype_breakdown_electricity
    },
    alert_daytype_breakdown_electricity_kwh: {
      inherits_from: :alert_daytype_breakdown_electricity,
      yaxis_units:   :kwh
    },
    alert_daytype_breakdown_electricity_co2: {
      inherits_from: :alert_daytype_breakdown_electricity,
      yaxis_units:   :co2
    },
    alert_daytype_breakdown_electricity_£: {
      inherits_from: :alert_daytype_breakdown_electricity,
      yaxis_units:   :£,
    },
    alert_daytype_breakdown_electricity_£current: {
      inherits_from: :alert_daytype_breakdown_electricity_£,
      yaxis_units:   :£current,
    },
    group_by_week_electricity: {
      name:             'By Week: Electricity',
      chart1_type:      :column,
      chart1_subtype:   :stacked,
      meter_definition: :allelectricity,
      x_axis:           :week,
      series_breakdown: :daytype,
      yaxis_units:      :kwh,
      yaxis_scaling:    :none,
      timescale:        :year
    },
    management_dashboard_group_by_week_electricity: {
      inherits_from:    :group_by_week_electricity,
      x_axis:           ChartDynamicXAxis.standard_up_to_1_year_dynamic_x_axis,
      community_use:    { filter: :all, aggregate: :community_use, split_electricity_baseload: true },
      timescale:        :up_to_a_year
    },

    test_economic_costs_electric_by_week_unlimited_£: {
      name:             'By Week: <%= meter.fuel_type.capitalize %> Unlimited £',
      inherits_from:    :management_dashboard_group_by_week_electricity,
      yaxis_units:      :£,
      timescale:        nil
    },
    test_economic_costs_electric_by_week_unlimited_co2: {
      name:             'By Week: <%= meter.fuel_type.capitalize %> Unlimited co2',
      inherits_from:    :test_economic_costs_electric_by_week_unlimited_£,
      yaxis_units:      :co2,
    },
    test_economic_costs_electric_by_week_unlimited_kwh: {
      name:             'By Week: <%= meter.fuel_type.capitalize %> Unlimited kwh',
      inherits_from:    :test_economic_costs_electric_by_week_unlimited_£,
      yaxis_units:      :kwh,
    },
    test_economic_costs_electric_by_week_unlimited_acc£: {
      inherits_from:    :test_economic_costs_electric_by_week_unlimited_£,
      series_breakdown: :daytype,
      yaxis_units:      :accounting_cost,
    },
    test_economic_costs_electric_by_week_unlimited_kwh_meter_breakdown: {
      name:             'By Week: <%= meter.fuel_type.capitalize %> Economic Cost Unlimited meter breakdown',
      inherits_from:    :group_by_week_electricity_meter_breakdown,
      yaxis_units:      :£,
      timescale:        nil
    },
    test_current_economic_costs_electric_by_week_unlimited_kwh_meter_breakdown: {
      name:             'By Week: <%= meter.fuel_type.capitalize %> Current Economic Cost Unlimited meter breakdown',
      inherits_from:    :test_economic_costs_electric_by_week_unlimited_kwh_meter_breakdown,
      yaxis_units:      :£current,
    },
    test_economic_costs_electric_by_datetime_year_£: {
      name:             'By Week: <%= meter.fuel_type.capitalize %> £ by datetime - 1 year',
      inherits_from:    :test_economic_costs_electric_by_week_unlimited_£,
      yaxis_units:      :£,
      x_axis:           :datetime,
      timescale:        :year
    },

    test_current_economic_costs_electric_by_week_unlimited_£: {
      name:             'By Week: <%= meter.fuel_type.capitalize %> Unlimited current £',
      inherits_from:    :test_economic_costs_electric_by_week_unlimited_£,
      yaxis_units:      :£current,
    },

    test_economic_costs_gas_by_week_unlimited_£: {
      inherits_from:    :test_economic_costs_electric_by_week_unlimited_£,
      meter_definition: :allheat,
    },
    test_economic_costs_gas_by_week_unlimited_co2: {
      inherits_from:    :test_economic_costs_electric_by_week_unlimited_co2,
      meter_definition:  :allheat,
    },
    test_economic_costs_gas_by_week_unlimited_kwh: {
      inherits_from:    :test_economic_costs_electric_by_week_unlimited_kwh,
      meter_definition: :allheat,
    },
    test_economic_costs_gas_by_week_unlimited_kwh_meter_breakdown: {
      inherits_from:    :test_economic_costs_electric_by_week_unlimited_kwh_meter_breakdown,
      meter_definition: :allheat,
    },
    test_economic_costs_gas_by_datetime_year_£: {
      inherits_from:    :test_economic_costs_electric_by_datetime_year_£,
      meter_definition: :allheat
    },
    # ============================================================================================
    group_by_week_electricity_versus_benchmark: {
      name:                 'By Week: Electricity - compared with benchmark',
      chart1_type:          :line,
      series_breakdown:     :none,
      meter_definition:     :allelectricity,
      x_axis:               :week,
      yaxis_units:          :kwh,
      yaxis_scaling:        :none,
      timescale:            :year,
      benchmark:            { calculation_types: %i[benchmark exemplar], config: { series_breakdown: :none } },
      replace_series_label: standard_series_label_substitution('Energy', 'school')
    },
    group_by_week_gas_versus_benchmark: {
      inherits_from: :group_by_week_electricity_versus_benchmark,
      name:                 'By Week: Gas - compared with benchmark',
      meter_definition:     :allheat,
      benchmark:            { calculation_types: %i[average benchmark exemplar], config: { series_breakdown: :none } },
    },
    group_by_week_electricity_versus_benchmark_line: {
      inherits_from: :group_by_week_electricity_versus_benchmark,
      chart1_type:      :column,
      chart1_subtype:   :stacked,
      series_breakdown: :daytype,
      change_series_chart_configuration:  { series_names: ['benchmark', 'exemplar'], chart1_type: :line }
    },
    group_by_week_electricity_versus_benchmark_line_on_y2: {
      inherits_from: :group_by_week_electricity_versus_benchmark_line,
      change_series_chart_configuration:  { series_names: ['benchmark', 'exemplar'], axis: :y2 }
    },
    electricity_by_day_of_week_tolerant_versus_benchmarks: {
      inherits_from:                      :electricity_by_day_of_week_tolerant,
      replace_series_label:               standard_series_label_substitution('Energy', 'school day'),
      benchmark:                          { calculation_types: %i[benchmark exemplar], config: { series_breakdown: :none } },
      change_series_chart_configuration:  { series_names: ['benchmark', 'exemplar'], chart1_type: :line }
    },
    baseload_versus_benchmarks: {
      inherits_from:                      :baseload,
      replace_series_label:               standard_series_label_substitution('BASELOAD', 'baseload'),
      benchmark:                          { calculation_types: %i[benchmark exemplar] },
      change_series_chart_configuration:  { series_names: ['benchmark', 'exemplar'], chart1_type: :line }
    },
    intraday_line_school_days_reduced_data_versus_benchmarks: {
      name:                               'Comparison of intraday consumption with benchmarks',
      inherits_from:                      :intraday_line_school_days_reduced_data,
      replace_series_label:               standard_series_label_substitution('Energy', 'school day'),
      benchmark:                          { calculation_types: %i[benchmark exemplar] },
      change_series_chart_configuration:  { series_names: ['benchmark', 'exemplar'], chart1_type: :line },
      timescale:                          :up_to_a_year
    },
    intraday_line_school_days_gas_reduced_data_versus_benchmarks: {
      inherits_from: :intraday_line_school_days_reduced_data_versus_benchmarks,
      name:                 'By Week: Gas - compared with benchmark - intraday',
      meter_definition:     :allheat,
      benchmark:                          { calculation_types: %i[average benchmark exemplar] },
      change_series_chart_configuration:  { series_names: ['average', 'benchmark', 'exemplar'], chart1_type: :line },
    },
    electricity_co2_last_year_weekly_with_co2_intensity: {
      name:             'The carbon emissions of your school and the carbon intensity of the National Electricity Grid over the last year',
      inherits_from:    :group_by_week_electricity,
      yaxis_units:      :co2,
      y2_axis:          :gridcarbon
    },
    electricity_co2_last_year_weekly_with_co2_intensity_co2_only: {
      inherits_from:    :electricity_co2_last_year_weekly_with_co2_intensity,
      restrict_y1_axis:   [:co2]
    },
    electricity_co2_last_year_weekly_with_co2_intensity_unmodified: {
      inherits_from:    :electricity_co2_last_year_weekly_with_co2_intensity,
      meter_definition: :allelectricity_unmodified,
      restrict_y1_axis:  [:co2]
    },
    electricity_co2_last_7_days_with_co2_intensity: {
      name:             'Variation in the electricity carbon emissions of your school over the last week',
      inherits_from:    :electricity_co2_last_year_weekly_with_co2_intensity,
      x_axis:           :datetime,
      timescale:        :week
    },
    electricity_co2_last_7_days_with_co2_intensity_unmodified: {
      inherits_from:    :electricity_co2_last_year_weekly_with_co2_intensity,
      meter_definition: :allelectricity_unmodified,
      x_axis:           :datetime,
      timescale:        :week
    },
    electricity_kwh_last_7_days_with_co2_intensity: {
      name:             '', # chart 2 of 2 in a section of the carbon emissions tab, dont want header
      inherits_from:    :electricity_co2_last_7_days_with_co2_intensity,
      yaxis_units:      :kwh
    },
    electricity_kwh_last_7_days_with_co2_intensity_unmodified: {
      inherits_from:    :electricity_kwh_last_7_days_with_co2_intensity,
      meter_definition: :allelectricity_unmodified
    },
    alert_group_by_week_electricity: {
      inherits_from:    :group_by_week_electricity,
      yaxis_units:      :£
    },
    storage_heater_group_by_week: {
      name:                 'Information on your school’s storage heater electricity consumption',
      inherits_from:        :group_by_week_electricity,
      meter_definition:     :storage_heater_meter,
      replace_series_label: [[Series::DayType::SCHOOLDAYCLOSED, Series::DayType::STORAGE_HEATER_CHARGE]],
      y2_axis:              :degreedays
    },
    management_dashboard_group_by_week_storage_heater: {
      inherits_from:        :storage_heater_group_by_week,
      x_axis:               ChartDynamicXAxis.standard_up_to_1_year_dynamic_x_axis,
      timescale:            :up_to_a_year
    },
    storage_heater_by_day_of_week: {
      name:               'Storage heater usage by day of the week',
      inherits_from:      :gas_by_day_of_week,
      replace_series_label: [[Series::DayType::SCHOOLDAYCLOSED, Series::DayType::STORAGE_HEATER_CHARGE]],
      meter_definition:   :storage_heater_meter
    },
    storage_heater_by_day_of_week_tolerant:  {
      inherits_from:    :storage_heater_by_day_of_week,
      timescale:        :up_to_a_year
    },
    storage_heater_group_by_week_long_term: {
      name:               'Storage heater electricity consumption over a longer time period',
      inherits_from:      :storage_heater_group_by_week,
      timescale:          nil
    },
    storage_heater_thermostatic: {
      name:               'Thermostatic control',
      inherits_from:      :thermostatic,
      humanize_legend:    true,
      meter_definition:   :storage_heater_meter,
=begin
      trendlines:       [
        'heating occupied all days'
      ]
=end
    },
    adhoc_test_chart: {
      name:               'Adhoc chart test',
      timescale:          [{ day: 0 }],
      x_axis:             :datetime,
      meter_definition:   :allheat,
      yaxis_units:        :kwh,
      series_breakdown:   :daytype,
      chart1_type:        :column,
      chart1_subtype:     :stacked,
      asof_date:          Date.new(2019, 2, 18)
    },
    activities_school_day_electricity_cost: {
      name:               'School day electricity cost',
      timescale:          [{ schoolday: 0 }],
      x_axis:             :datetime,
      meter_definition:   :allelectricity,
      yaxis_units:        :£,
      series_breakdown:   :daytype,
      chart1_type:        :column,
      chart1_subtype:     :stacked,
    },
    activities_school_day_gas_cost: {
      inherits_from:      :activities_school_day_electricity_cost,
      name:               'School day gas cost',
      meter_definition:   :allheat
    },
    activities_weekend_day_electricity_cost: {
      inherits_from:      :activities_school_day_electricity_cost,
      timescale:          [{ weekendday: 0 }],
      name:               'Weekend day electricity cost',
    },
    activities_weekend_day_gas_cost: {
      inherits_from:      :activities_weekend_day_electricity_cost,
      name:               'Weekend day gas cost',
      meter_definition:   :allheat
    },
    activities_14_days_daytype_electricity_cost: {
      inherits_from:      :activities_school_day_electricity_cost,
      timescale:          [{ day: -13..0 }],
      x_axis:             :day,
      x_axis_reformat:    { date: '%a %d %b %Y' },
      name:               'Last 14 days electricity costs',
    },
    activities_14_days_daytype_gas_cost: {
      inherits_from:      :activities_2_weeks_daytype_electricity_cost,
      name:               'Last 14 days gas costs',
      meter_definition:   :allheat
    },
    activities_2_weeks_daytype_electricity_cost: {
      inherits_from:      :activities_14_days_daytype_electricity_cost,
      timescale:          [{ workweek: -1..0 }],
      name:               'Last 2 weeks electricity costs',
    },
    activities_2_weeks_daytype_gas_cost: {
      inherits_from:      :activities_2_weeks_daytype_electricity_cost,
      name:               'Last 2 weeks gas costs',
      meter_definition:   :allheat
    },
    storage_heater_intraday_current_year: {
      name:               'Storage heater power consumption',
      inherits_from:      :gas_heating_season_intraday,
      meter_definition:   :storage_heater_meter
    },
    storage_heater_intraday_current_year_kw: {
      name:               'Storage heater intraday profile (kw) for year to date',
      chart1_type:        :line,
      inherits_from:      :storage_heater_intraday_current_year,
      yaxis_units:        :kw
    },
    intraday_line_school_last7days_storage_heaters:  {
      inherits_from:    :intraday_line_school_last7days,
      name:             'Last 7 days storage heater power consumption',
      meter_definition: :storage_heater_meter
    },
    heating_on_off_by_week_storage_heater: {
      inherits_from:    :heating_on_off_by_week,
      name:             'How many days the heating is left on during the year',
      meter_definition: :storage_heater_meter
    },
    solar_pv_group_by_week: {
      name:               'Solar PV by week of the year',
      inherits_from:      :storage_heater_group_by_week,
      restrict_y1_axis:   [:kwh],
      y2_axis:            :irradiance,
      meter_definition:   :solar_pv_meter
    },
    solar_pv_group_by_week_by_submeter: {
      name:               'Solar PV by week of the year',
      inherits_from:      :solar_pv_group_by_week,
      meter_definition: :allelectricity,
      series_breakdown:   :submeter
    },
    pupil_dashboard_solar_pv_one_week_by_day: {
      name:               'Solar PV for last week',
      inherits_from:      :solar_pv_group_by_week_by_submeter,
      x_axis:           :day,
      timescale:        {workweek: 0}
    },
    pupil_dashboard_solar_pv_one_week_by_day_previous_week: {
      name:               'Solar PV for previous week',
      inherits_from:      :pupil_dashboard_solar_pv_one_week_by_day,
      timescale:        {workweek: -1}
    },
    solar_pv_group_by_month: {
      name:               'Analysis of your school’s solar PV panels',
      inherits_from:      :solar_pv_group_by_week_by_submeter,
      filter:                   {
        submeter: [
          :mains_consume,
          :export,
          :self_consume
        ]
      },
      x_axis:           :month,
      timescale:        :up_to_a_year
    },
    solar_pv_group_by_month_dashboard_overview: {
      inherits_from:      :solar_pv_group_by_month,
      reason:             'simplified text used for overview page, requires different chart name'
    },
    management_dashboard_group_by_month_solar_pv: {
      inherits_from:      :solar_pv_group_by_month,
      x_axis:           ChartDynamicXAxis.standard_solar_up_to_1_year_dynamic_x_axis,
    },
    management_dashboard_group_by_month_solar_pv_unlimited: {
      inherits_from:    :management_dashboard_group_by_month_solar_pv,
      timescale:        nil
    },
    solar_pv_last_7_days_by_submeter: {
      name:               'The last 7 days of your school’s electricity consumption',
      inherits_from:      :solar_pv_group_by_week,
      timescale:          [{ day: -6...0 }],
      x_axis:             :datetime,
      meter_definition:   :allelectricity,
      series_breakdown:   :submeter,
      filter:                   {
        submeter: [
          :mains_consume,
          :export,
          :self_consume
        ]
      },
    },
    solar_pv_single_day_adhoc_test: {
      name: 'adhoc single day solar PV test chart',
      inherits_from: :solar_pv_last_7_days_by_submeter,
      timescale:  :day,
      asof_date:   Date.new(2022, 8, 8)
    },
    electricity_by_day:  {
      inherits_from:    :group_by_week_electricity,
      name:             'By Day: Electricity',
      x_axis:           :day,
      timescale:        :week
    },
    electricity_by_datetime:  {
      inherits_from:    :group_by_week_electricity,
      name:             'By Time: Electricity',
      x_axis:           :datetime,
      timescale:        :day
    },
    electricity_by_datetime_line_kw:  {
      inherits_from:    :electricity_by_datetime,
      chart1_type:      :line,
      series_breakdown: :none,
      yaxis_units:      :kw
    },
    group_by_week_electricity_unlimited: {
      name:             'By Week: Electricity (multi-year)',
      chart1_type:      :column,
      chart1_subtype:   :stacked,
      zoomable:         true,
      meter_definition: :allelectricity,
      x_axis:           :week,
      series_breakdown: :daytype,
      yaxis_units:      :kwh,
      yaxis_scaling:    :none
    },
    group_by_week_electricity_meter_breakdown: {
      name:             'By Week: Electricity (Meter Breakdown)',
      meter_definition: :allelectricity,
      inherits_from:    :group_by_week_gas_meter_breakdown,
      series_breakdown: :meter,
      y2_axis:          nil
    },
    temp_test: {
      inherits_from:    :group_by_week_electricity_meter_breakdown,
      x_axis:           :day,
      timescale:        :week
    },
    temp_test2: {
      inherits_from:    :temp_test,
      x_axis:           :datetime,
      timescale:        :day
    },
    group_by_week_electricity_meter_breakdown_one_year: {
      inherits_from:    :group_by_week_electricity_meter_breakdown,
      timescale:        :up_to_a_year
    },
    group_by_week_gas: {
      name:             'By Week: Gas',
      chart1_type:      :column,
      chart1_subtype:   :stacked,
      meter_definition: :allheat,
      x_axis:           :week,
      series_breakdown: :daytype,
      yaxis_units:      :kwh,
      yaxis_scaling:    :none,
      y2_axis:          :degreedays,
      timescale:        :year
    },
    management_dashboard_group_by_week_gas: {
      inherits_from:    :group_by_week_gas,
      x_axis:           ChartDynamicXAxis.standard_up_to_1_year_dynamic_x_axis,
      timescale:        :up_to_a_year
    },
    alert_group_by_week_gas: {
      inherits_from:    :group_by_week_gas,
      yaxis_units:      :£
    },
    alert_group_by_week_storage_heaters: {
      inherits_from:      :alert_group_by_week_gas,
      name:               'By Week: Storage Heaters',
      replace_series_label: [[Series::DayType::SCHOOLDAYCLOSED, Series::DayType::STORAGE_HEATER_CHARGE]],
      meter_definition:   :storage_heater_meter
    },
    alert_group_by_week_electricity_14_months: {
      inherits_from:    :alert_group_by_week_electricity,
      timescale:        { month: -13..0 } # 14 months so can see previous year's holiday (max requirement - 1 year + 6 weeks summer holiday
    },
    alert_group_by_week_gas_14_months: {
      inherits_from:    :alert_group_by_week_gas,
      timescale:        { month: -13..0 } # 14 months so can see previous year's holiday (max requirement - 1 year + 6 weeks summer holiday
    },
    alert_group_by_week_storage_heaters_14_months: {
      inherits_from:    :alert_group_by_week_gas,
      timescale:        { month: -13..0 } # 14 months so can see previous year's holiday (max requirement - 1 year + 6 weeks summer holiday
    },
    alert_group_by_week_electricity_4_months: {
      inherits_from:    :alert_group_by_week_electricity,
      timescale:        { month: -3..0 } # previous holiday alert, 4 months is minium required to cover, Whitsun (x 1 wk), term (x6), sum hol (x6), term (x3)
    },
    alert_group_by_week_gas_4_months: {
      inherits_from:    :alert_group_by_week_gas,
      timescale:        { month: -3..0 } # 14 months so can see previous year's holiday (max requirement - 1 year + 6 weeks summer holiday
    },
    group_by_week_carbon: {
      name:             'Calculating your schools total carbon emissions, including transport and food',
      inherits_from:    :group_by_week_gas,
      series_breakdown: :none,
      yaxis_units:      :co2,
      y2_axis:          :gascarbon
    },
    group_by_week_gas_unlimited: {
      name:             'By Week: Gas (multi-year)',
      chart1_type:      :column,
      chart1_subtype:   :stacked,
      zoomable:         true,
      meter_definition: :allheat,
      x_axis:           :week,
      series_breakdown: :daytype,
      yaxis_units:      :kwh,
      yaxis_scaling:    :none,
      y2_axis:          :degreedays
    },
    group_by_week_gas_meter_breakdown: {
      name:             'By Week: Gas (Meter Breakdown)',
      inherits_from:    :group_by_week_gas_unlimited,
      series_breakdown: :meter
    },
    group_by_week_gas_meter_breakdown_one_year: {
      inherits_from:    :group_by_week_gas_meter_breakdown,
      timescale:        :up_to_a_year
    },
    group_by_month_gas_meter_breakdown: {
      name:             'By Month: Gas (Meter Breakdown)',
      chart1_type:      :column,
      chart1_subtype:   :stacked,
      meter_definition: :allheat,
      series_breakdown: :meter,
      timescale:        :twelve_months,
      x_axis:           :month,
      yaxis_units:      :kwh,
      yaxis_scaling:    :none,
      y2_axis:          :degreedays
    },
    group_by_month_electricity_meter_breakdown: {
      name:             'By Month: Electricity (Meter Breakdown)',
      chart1_type:      :column,
      chart1_subtype:   :stacked,
      meter_definition: :allelectricity,
      series_breakdown: :meter,
      timescale:        :twelve_months,
      x_axis:           :month,
      yaxis_units:      :kwh,
      yaxis_scaling:    :none
    },
    group_by_year_gas_meter_breakdown: {
      name:             'By Year: Gas (Meter Breakdown)',
      chart1_type:      :column,
      chart1_subtype:   :stacked,
      meter_definition: :allheat,
      series_breakdown: :meter,
      x_axis:           :year,
      yaxis_units:      :kwh,
      yaxis_scaling:    :none,
      y2_axis:          :degreedays,
      reverse_xaxis:    true
    },
    group_by_year_electricity_meter_breakdown: {
      name:             'By Year: Electricity (Meter Breakdown)',
      chart1_type:      :column,
      chart1_subtype:   :stacked,
      meter_definition: :allelectricity,
      series_breakdown: :meter,
      x_axis:           :year,
      yaxis_units:      :kwh,
      yaxis_scaling:    :none,
      reverse_xaxis:    true
    },
    group_by_year_gas_unlimited_meter_breakdown_heating_model_fitter: {
      name:             'Gas meter breakdown by year',
      inherits_from:    :group_by_week_gas_unlimited,
      x_axis:           :year,
      series_breakdown: :meter
    },
    group_by_week_gas_kw: {
      name:             'By Week: Gas',
      chart1_type:      :column,
      chart1_subtype:   :stacked,
      meter_definition: :allheat,
      x_axis:           :week,
      series_breakdown: :daytype,
      yaxis_units:      :kw,
      yaxis_scaling:    :none,
      y2_axis:          :degreedays
    },
    group_by_week_gas_kwh: {
      name:             'By Week: Gas',
      chart1_type:      :column,
      chart1_subtype:   :stacked,
      meter_definition: :allheat,
      x_axis:           :week,
      series_breakdown: :daytype,
      yaxis_units:      :kwh,
      yaxis_scaling:    :none,
      y2_axis:          :degreedays
    },
    group_by_week_gas_kwh_pupil: {
      name:             'By Week: Gas',
      chart1_type:      :column,
      chart1_subtype:   :stacked,
      meter_definition: :allheat,
      x_axis:           :week,
      series_breakdown: :daytype,
      yaxis_units:      :kwh,
      yaxis_scaling:    :per_pupil,
      y2_axis:          :degreedays
    },
    group_by_week_gas_co2_floor_area: {
      name:             'By Week: Gas',
      chart1_type:      :column,
      chart1_subtype:   :stacked,
      meter_definition: :allheat,
      x_axis:           :week,
      series_breakdown: :daytype,
      yaxis_units:      :co2,
      yaxis_scaling:    :per_floor_area,
      y2_axis:          :degreedays
    },
    group_by_week_gas_library_books: {
      name:             'By Week: Gas',
      chart1_type:      :column,
      chart1_subtype:   :stacked,
      meter_definition: :allheat,
      x_axis:           :week,
      series_breakdown: :daytype,
      yaxis_units:      :library_books,
      yaxis_scaling:    :none,
      y2_axis:          :degreedays
    },
    gas_latest_years:  {
      name:             'Gas Use Over Last Few Years (to date)',
      chart1_type:      :column,
      chart1_subtype:   :stacked,
      series_breakdown: :daytype,
      x_axis:           :year,
      meter_definition: :allheat,
      yaxis_units:      :kwh,
      yaxis_scaling:    :none,
      y2_axis:          :temperature
    },
    gas_latest_academic_years:  {
      name:             'Gas Use Over Last Few Academic Years',
      chart1_type:      :bar,
      chart1_subtype:   :stacked,
      series_breakdown: :daytype,
      x_axis:           :academicyear,
      meter_definition: :allheat,
      yaxis_units:      :kwh,
      yaxis_scaling:    :none
    },
    gas_by_day_of_week:  {
      name:             'Gas Use By Day of the Week',
      chart1_type:      :column,
      chart1_subtype:   :stacked,
      series_breakdown: :daytype,
      x_axis:           :dayofweek,
      timescale:        :year,
      meter_definition: :allheat,
      yaxis_units:      :kwh,
      yaxis_scaling:    :none,
      subtitle:         :daterange
    },
    gas_by_day_of_week_tolerant:  {
      inherits_from:    :gas_by_day_of_week,
      timescale:        :up_to_a_year,
    },
    electricity_by_day_of_week:  {
      name:             'Electricity Use By Day of the Week',
      chart1_type:      :column,
      chart1_subtype:   :stacked,
      series_breakdown: :daytype,
      x_axis:           :dayofweek,
      timescale:        :year,
      meter_definition: :allelectricity,
      yaxis_units:      :kwh,
      yaxis_scaling:    :none,
      subtitle:         :daterange
    },
    electricity_by_day_of_week_tolerant:  {
      inherits_from:    :electricity_by_day_of_week,
      timescale:        :up_to_a_year,
    },
    electricity_baseload_by_day_of_week:  {
      inherits_from:    :electricity_by_day_of_week_tolerant,
      series_breakdown: :baseload,
      yaxis_units:      :kw,
    },
    electricity_by_month_acyear_0_1:  {
      name:             'Electricity Use By Month (previous 2 academic years)',
      chart1_type:      :column,
      # chart1_subtype:   :stacked,
      series_breakdown: :none,
      x_axis:           :month,
      timescale:        [{ fixed_academic_year: 0 }, { fixed_academic_year: -1 }],
      meter_definition: :allelectricity,
      yaxis_units:      :kwh,
      yaxis_scaling:    :none
    },
    electricity_by_month_year_0_1:  {
      name:             'Electricity Use By Month (last 2 years)',
      inherits_from:    :electricity_by_month_acyear_0_1,
      timescale:        [{ twelve_months: 0 }, { twelve_months: -1 }],
      ignore_single_series_failure: true
    },
    # 8 finance tab charts
    electricity_by_month_year_0_1_finance_advice: {
      x_axis:           :month,
      name:             'Energy Costs',
      timescale:        [{ up_to_a_year: 0 }, { up_to_a_year: -1 }],
      ignore_single_series_failure: true,
      inherits_from:    :electricity_by_month_year_0_1
    },
    electricity_cost_comparison_last_2_years_accounting: {
      name:              '',
      x_axis:            :month,
      inherits_from:     :electricity_cost_comparison_last_2_years,
      timescale:         [{ fixed_academic_year: 0 }, { fixed_academic_year: -1 }],
      ignore_single_series_failure: true,
      yaxis_units:       :accounting_cost,
      meter_definition:  :allelectricity_unmodified
    },
    electricity_cost_1_year_accounting_breakdown: {
      name:             '',
      inherits_from:    :electricity_cost_comparison_last_2_years_accounting_breakdown,
      timescale:        [{ up_to_a_year: 0 }],
      ignore_single_series_failure: true,
      chart1_subtype:   :stacked,
      meter_definition:  :allelectricity_unmodified
    },
    pie_chart_1_year_accounting_breakdown: {
      name:             '',
      inherits_from:    :electricity_cost_1_year_accounting_breakdown,
      timescale:        [{ up_to_a_year: 0 }],
      chart1_type:      :pie,
      chart1_subtype:   nil,
      x_axis:           :nodatebuckets
    },
    electricity_cost_1_year_accounting_breakdown_group_by_week: {
      inherits_from:    :electricity_cost_1_year_accounting_breakdown,
      x_axis:           :week
    },
    electricity_cost_1_year_accounting_breakdown_group_by_day: {
      inherits_from:    :electricity_cost_1_year_accounting_breakdown,
      x_axis:           :day
    },
    accounting_cost_daytype_breakdown_electricity: {
      name:             '',
      yaxis_units:      :accounting_cost,
      timescale:        :up_to_a_year,
      inherits_from:    :daytype_breakdown_electricity
    },
    gas_by_month_year_0_1_finance_advice: {
      x_axis:           :month,
      name:             'Gas Costs',
      timescale:        [{ up_to_a_year: 0 }, { up_to_a_year: -1 }],
      ignore_single_series_failure: true,
      inherits_from:    :gas_by_month_year_0_1
    },
    gas_cost_comparison_last_2_years_accounting: {
      name:             '',
      inherits_from:    :electricity_cost_comparison_last_2_years,
      timescale:        [{ up_to_a_year: 0 }, { up_to_a_year: -1 }],
      ignore_single_series_failure: true,
      meter_definition: :allheat
    },
    gas_cost_1_year_accounting_breakdown: {
      name:             '',
      inherits_from:    :electricity_cost_1_year_accounting_breakdown,
      meter_definition: :allheat
    },
    accounting_cost_daytype_breakdown_gas: {
      name:             '',
      yaxis_units:      :accounting_cost,
      timescale:        :up_to_a_year,
      inherits_from: :daytype_breakdown_gas
    },
    # TODO(PH 12Jan2020) remove once SH/PV accounting testing complete:
    acc1: {
      meter_definition: :allelectricity_unmodified,
      inherits_from: :electricity_by_month_year_0_1_finance_advice
    },
    acc2: {
      meter_definition: :allelectricity_unmodified,
      inherits_from: :electricity_cost_comparison_last_2_years_accounting
    },
    acc3: {
      meter_definition: :allelectricity_unmodified,
      inherits_from: :electricity_cost_1_year_accounting_breakdown
    },
    acc4: {
      meter_definition: :allelectricity_unmodified,
      inherits_from: :accounting_cost_daytype_breakdown_electricity
    },
    gas_by_month_year_0_1: {
      inherits_from:    :electricity_by_month_year_0_1,
      name:             'Gas Use By Month (last 2 years)',
      meter_definition: :allheat
    },
    gas_by_month_acyear_0_1: {
      inherits_from:    :gas_by_month_year_0_1,
      name:             'Gas Use By Month (last 2 academic years)',
      timescale:        [{ fixed_academic_year: 0 }, { fixed_academic_year: -1 }],
    },
    electricity_cost_comparison_last_2_years: {
      x_axis:           :month,
      chart1_type:      :column,
      inherits_from:    :electricity_by_month_year_0_1,
      yaxis_units:      :£
    },
    electricity_cost_comparison_last_2_years_accounting_breakdown: {
      name:             'Energy Costs', # title for 1st heading of introductory text for web page
      inherits_from:    :electricity_cost_comparison_last_2_years_accounting,
      series_breakdown: :accounting_cost,
      meter_definition:  :allelectricity_unmodified
    },
    gas_cost_comparison_last_2_years_accounting_breakdown: {
      name:             'Gas accounting cost by month for the last year',
      inherits_from:    :electricity_cost_comparison_last_2_years_accounting_breakdown,
      meter_definition: :allheat
    },
    electricity_cost_comparison_1_year_accounting_breakdown_by_week: {
      name:             'Electricity accounting cost breakdown by week for the last year',
      inherits_from:    :electricity_cost_1_year_accounting_breakdown,
      x_axis:           :week
    },
    gas_cost_comparison_1_year_accounting_breakdown_by_week: {
      name:             'Gas accounting cost breakdown by week for the last year',
      meter_definition: :allheat,
      inherits_from:    :electricity_cost_1_year_accounting_breakdown,
      x_axis:           :week,
      y2_axis:          :degreedays
    },
    gas_cost_comparison_1_year_economic_breakdown_by_week: {
      name:             'Gas economic cost breakdown by week for the last year',
      inherits_from:    :gas_cost_comparison_1_year_accounting_breakdown_by_week,
      series_breakdown: :none,
      yaxis_units:      :£,
      x_axis:           :week
    },
    electricity_2_week_accounting_breakdown: {
      name:             'Electricity accounting cost breakdown by day for last 2 weeks',
      inherits_from:    :electricity_cost_comparison_1_year_accounting_breakdown_by_week,
      timescale:        [{ day: -13...0 }],
      x_axis:           :day
    },
    electricity_1_year_intraday_accounting_breakdown: {
      name:             'Electricity costs for last year by time of day (accounting costs)',
      inherits_from:    :gas_heating_season_intraday,
      meter_definition: :allelectricity_unmodified,
      filter:           nil,
      series_breakdown: :accounting_cost,
      yaxis_units:      :£,
      chart1_subtype:   :stacked
    },
    electricity_1_year_intraday_kwh_breakdown: {
      name:             'Electricity kWh usage intraday for last year for comparison with accounting version above',
      inherits_from:    :electricity_1_year_intraday_accounting_breakdown,
      series_breakdown: :none,
      yaxis_units:      :kwh
    },
    gas_1_year_intraday_accounting_breakdown: {
      name:             'Gas costs for last year by time of day (accounting costs)',
      inherits_from:    :electricity_1_year_intraday_accounting_breakdown,
      meter_definition: :allheat
    },
    gas_1_year_intraday_economic_breakdown: {
      name:             'Gas costs for last year by time of day (economic costs)',
      series_breakdown: :none,
      inherits_from:    :gas_1_year_intraday_accounting_breakdown,
      yaxis_units:      :£
    },
    gas_1_year_intraday_kwh_breakdown: {
      name:             'Gas kWh usage intraday for last year for comparison with accounting version above',
      inherits_from:    :gas_1_year_intraday_accounting_breakdown,
      series_breakdown: :none,
      yaxis_units:      :kwh
    },
    gas_heating_season_intraday: {
      name:             'Intraday Gas Consumption (during heating season)',
      chart1_type:      :column,
      meter_definition: :allheat,
      timescale:        :year,
      filter:           { daytype: [ Series::DayType::SCHOOLDAYOPEN, Series::DayType::SCHOOLDAYCLOSED ], heating: true },
      series_breakdown: :none,
      x_axis:           :intraday,
      yaxis_units:      :kwh,
      yaxis_scaling:    :none,
      subtitle:         :daterange
    },
    community_use_test_electricity: {
      name:             'Community use test chart electricity',
      chart1_type:      :column,
      chart1_subtype:   :stacked,
      meter_definition: :allelectricity,
      timescale:        :year,
      series_breakdown: :daytype,
      x_axis:           :intraday,
      yaxis_units:      :kwh,
      yaxis_scaling:    :none,
      subtitle:         :daterange,
      community_use:  { filter: :all, aggregate: :community_use, split_electricity_baseload: true }
    },
    community_use_test_electricity_community_use_only: {
      name:          'Community use test chart electricity community use only',
      inherits_from: :community_use_test_electricity,
      community_use:  { filter: :community_only, aggregate: :none }
    },
    community_use_test_electricity_school_use_only: {
      name:          'Community use test chart electricity school use only',
      inherits_from: :community_use_test_electricity,
      community_use:  { filter: :school_only, aggregate: :none }
    },
    community_use_test_electricity_community_use_only_aggregated: {
      name:          'Community use test chart electricity community use only aggregated - series name = community',
      inherits_from: :community_use_test_electricity,
      community_use:  { filter: :community_only, aggregate: :community_use }
    },
    community_use_test_gas: {
      name:          'Community use test chart gas',
      meter_definition: :allheat,
      inherits_from: :community_use_test_electricity,
    },
    gas_heating_season_intraday_up_to_1_year: {
      inherits_from: :gas_heating_season_intraday,
      timescale:        :up_to_a_year
    },
    gas_heating_season_intraday_£: { # temporary chart 18Mar19 to bug fix non £ scaling intradat kWh charts
      inherits_from: :gas_heating_season_intraday,
      yaxis_units: :£
    },
    alert_gas_heating_season_intraday: {
      inherits_from: :gas_heating_season_intraday_up_to_1_year,
      yaxis_units: :£
    },
    gas_intraday_schoolday_last_year: { # used by heating regression fitter
      name:             'Intra-school day gas consumption profile',
      inherits_from:    :gas_heating_season_intraday,
      series_breakdown: :none,
      filter:           { daytype: [ Series::DayType::SCHOOLDAYOPEN, Series::DayType::SCHOOLDAYCLOSED ] }
    },
    meter_breakdown_pie_1_year: { # used by heating regression fitter
      name:             'Breakdown by meter (this year): Gas',
      inherits_from:    :daytype_breakdown_gas,
      x_axis:           :nodatebuckets,
      series_breakdown: :meter
    },
    group_by_week_gas_model_fitting_one_year: { # aliased for different advice
      name:             'By Week: Gas (1 year)',
      inherits_from:    :group_by_week_gas_unlimited,
      timescale:        :year
    },
    group_by_week_gas_model_fitting_unlimited: { # aliased for different advice
      name:             'By Week: Gas (all data)',
      inherits_from:    :group_by_week_gas_unlimited
    },
    gas_by_day_of_week_model_fitting: {
      inherits_from:    :gas_by_day_of_week
    },
    gas_longterm_trend_model_fitting: {
      inherits_from:    :gas_longterm_trend
    },
    thermostatic_regression: {
      name:             'Thermostatic (Regression_Model Testing)',
      chart1_type:      :scatter,
      meter_definition: :allheat,
      timescale:        :year,
      series_breakdown: %i[model_type temperature],
      x_axis:           :day,
      yaxis_units:      :kwh,
      yaxis_scaling:    :none
    },
    thermostatic_regression_simple_school_day: {
      name:             'Thermostatic (School Day) - simple model',
      inherits_from:    :thermostatic_regression,
      series_breakdown: %i[model_type temperature],
      trendlines:       %i[heating_occupied_all_days summer_occupied_all_days],
      filter:           { model_type: %i[heating_occupied_all_days summer_occupied_all_days] },
      model:            :simple_regression_temperature
    },

    thermostatic_regression_simple_school_day_non_heating_non_regression: {
      name:               'Thermostatic (School Day) - heating - non-heating separation non regression',
      inherits_from:      :thermostatic_regression_simple_school_day,
      non_heating_model:  :fixed_single_value_temperature_sensitive_regression_model
    },
    thermostatic_regression_simple_school_day_non_heating_regression: {
      name:               'Thermostatic (School Day) - heating - non-heating separation regression',
      inherits_from:      :thermostatic_regression_simple_school_day,
      non_heating_model:  :temperature_sensitive_regression_model
    },
    thermostatic_regression_simple_school_day_non_heating_regression_covid_tolerant: {
      name:               'Thermostatic (School Day) - heating - non-heating separation regression, covid tolerant',
      inherits_from:      :thermostatic_regression_simple_school_day,
      non_heating_model:  :temperature_sensitive_regression_model_covid_tolerant
    },

    seasonal_simple_school_day_non_heating_non_regression: {
      name:               'Thermostatic (School Day) - heating - non-heating separation non regression',
      inherits_from:      :heating_on_off_by_week,
      non_heating_model:  :fixed_single_value_temperature_sensitive_regression_model
    },
    seasonal_simple_school_day_non_heating_regression: {
      name:               'Thermostatic (School Day) - heating - non-heating separation regression',
      inherits_from:      :heating_on_off_by_week,
      non_heating_model:  :temperature_sensitive_regression_model
    },
    seasonal_simple_school_day_non_heating_regression_covid_tolerant: {
      name:               'Thermostatic (School Day) - heating - non-heating separation regression, covid tolerant',
      inherits_from:      :heating_on_off_by_week,
      non_heating_model:  :temperature_sensitive_regression_model_covid_tolerant
    },


    thermostatic: {
      inherits_from:    :thermostatic_regression_simple_school_day,
      name:             'Thermostatic (Temperature v. Daily Consumption - current year)',
      subtitle:         :daterange
    },
    test_thermostatic_£: {
      inherits_from:  :thermostatic_regression_simple_school_day,
      yaxis_units:         :£
    },
    test_thermostatic_co2: {
      inherits_from:  :thermostatic_regression_simple_school_day,
      yaxis_units:    :co2
    },
    thermostatic_up_to_1_year: {
      inherits_from:    :thermostatic,
      name:             'Thermostatic (Temperature v. Daily Consumption)',
      timescale:        :up_to_a_year
    },
    thermostatic_regression_simple_all: {
      name:             'Thermostatic (All Categories) - simple model',
      inherits_from:    :thermostatic_regression,
      model:            :simple_regression_temperature,
      trendlines:       %i[
                          heating_occupied_all_days
                          weekend_heating
                          holiday_heating
                          summer_occupied_all_days
                          holiday_hotwater_only
                          weekend_hotwater_only
                        ],
    },
    thermostatic_regression_thermally_massive_school_day: {
      name:             'Thermostatic (School Day) - thermally massive model',
      inherits_from:    :thermostatic_regression_simple_school_day,
      model:            :thermal_mass_regression_temperature
    },
    thermostatic_regression_thermally_massive_all: {
      name:             'Thermostatic (All Categories) - thermally massive model',
      inherits_from:    :thermostatic_regression_simple_all,
      model:            :thermal_mass_regression_temperature,
      trendlines:       %i[
        heating_occupied_monday
        heating_occupied_tuesday
        heating_occupied_wednesday
        heating_occupied_thursday
        heating_occupied_friday
        weekend_heating
        holiday_heating
        summer_occupied_all_days
        holiday_hotwater_only
        weekend_hotwater_only
      ],
    },
    cusum_weekly_best_model: {
      inherits_from:    :cusum_weekly,
      model:            :best,
      timescale:        nil
    },
    thermostatic_winter_holiday_best: {
      name:             'Thermostatic (Winter Holiday)',
      inherits_from:    :thermostatic_regression,
      model:            :best,
      filter:           { model_type: :holiday_heating },
      trendlines:       %i[ holiday_heating ]
    },
    thermostatic_winter_weekend_best: {
      name:             'Thermostatic (Winter Weekend)',
      inherits_from:    :thermostatic_winter_holiday_best,
      filter:           { model_type: :weekend_heating },
      trendlines:       %i[ weekend_heating ]
    },
    thermostatic_summer_school_day_holiday_best: {
      name:             'Thermostatic (Summer Weekend and Holiday)',
      inherits_from:    :thermostatic_winter_holiday_best,
      filter:           { model_type: %i[summer_occupied_all_days holiday_hotwater_only] },
      trendlines:       %i[ summer_occupied_all_days holiday_hotwater_only ]
    },
    thermostatic_summer_weekend_best: {
      name:             'Thermostatic (Summer Weekend and Holiday)',
      inherits_from:    :thermostatic_winter_holiday_best,
      filter:           { model_type: :weekend_hotwater_only },
      trendlines:       %i[ weekend_hotwater_only ]
    },
    thermostatic_non_best: {
      name:             'Thermostatic (Days of minimal consumption)',
      inherits_from:    :thermostatic_winter_holiday_best,
      filter:           { model_type: :none }
    },
    cusum_simple: {
      name:             'CUSUM: simple model',
      inherits_from:    :cusum,
      model:            :simple_regression_temperature
    },
    cusum_thermal_mass: {
      name:             'CUSUM: thermal mass model model',
      inherits_from:    :cusum_simple,
      model:            :thermal_mass_regression_temperature
    },
    thermostatic_model_by_week: {
      name:             'Thermostatic model type by week',
      chart1_type:      :column,
      chart1_subtype:   :stacked,
      meter_definition: :allheat,
      x_axis:           :week,
      series_breakdown: :model_type,
      yaxis_units:      :kwh,
      yaxis_scaling:    :none,
      y2_axis:          :degreedays
    },
    heating_on_off_by_week: {
      name:                     'Heating season analysis',
      inherits_from:            :thermostatic_model_by_week,
      timescale:                :up_to_a_year,
      model:                    :best,
      series_breakdown:         :heating
    },
    heating_on_off_by_week_with_breakdown_all: {
      inherits_from:            :heating_on_off_by_week,
      series_breakdown:         :heating_daytype,
      add_day_count_to_legend:  true
    },
    heating_on_by_week_with_breakdown: {
      inherits_from:            :heating_on_off_by_week_with_breakdown_all,
      filter:                   {
                                  heating_daytype: [
                                    Series::HeatingDayType::SCHOOLDAYHEATING,
                                    Series::HeatingDayType::HOLIDAYHEATING,
                                    Series::HeatingDayType::WEEKENDHEATING
                                  ]
                                }
    },
    heating_on_by_week_with_breakdown_storage_heaters: {
      inherits_from:            :heating_on_by_week_with_breakdown,
      meter_definition: :storage_heater_meter
    },
    heating_on_by_week_with_breakdown_school_day_only: {
      inherits_from:  :heating_on_off_by_week_with_breakdown_all,
      filter: {
                heating_daytype: [
                  Series::HeatingDayType::SCHOOLDAYHEATING
                ]
              }
    },
    hot_water_kitchen_on_off_by_week_with_breakdown: {
      inherits_from:  :heating_on_off_by_week_with_breakdown_all,
      filter: {
                heating_daytype: [
                  Series::HeatingDayType::SCHOOLDAYHOTWATER,
                  Series::HeatingDayType::WEEKENDHOTWATER,
                  Series::HeatingDayType::HOLIDAYHOTWATER
                ]
              }
    },
    heating_on_off_by_week_heating_school_days_and_holidays_only: {
      inherits_from:    :heating_on_off_by_week,
      filter:            { heating: true }
    },
    heating_on_off_by_week_heating_school_non_school_days_only: {
      inherits_from:    :heating_on_off_by_week_heating_school_days_and_holidays_only,
      filter:           { daytype: [ Series::DayType::HOLIDAY, Series::DayType::WEEKEND ], heating: true },
      y2_axis:          nil
    },
    thermostatic_model_categories_pie_chart: {
      name:             'Categorised consumption by model',
      inherits_from:    :thermostatic_model_by_week,
      model:            :best,
      chart1_type:      :pie,
      chart1_subtype:   nil,
      y2_chart_type:    nil,
      y2_axis:          nil,
      x_axis:           :nodatebuckets,
      subtitle:         :daterange
    },
    heating_on_off_pie_chart: {
      name:             'Heating versus non-heating day gas consumption',
      inherits_from:    :heating_on_off_by_week,
      model:            :best,
      chart1_type:      :pie,
      chart1_subtype:   nil,
      y2_chart_type:    nil,
      y2_axis:          nil,
      x_axis:           :nodatebuckets,
      subtitle:         :daterange
    },
    thermostatic_non_heating_deprecated: {
      name:             'Thermostatic (Non Heating Season, School Day)',
      chart1_type:      :scatter,
      meter_definition: :allheat,
      timescale:        :year,
      filter:           { daytype: [ Series::DayType::SCHOOLDAYOPEN, Series::DayType::SCHOOLDAYCLOSED ], heating: false },
      series_breakdown: %i[heating heatingmodeltrendlines degreedays],
      x_axis:           :day,
      yaxis_units:      :kwh,
      yaxis_scaling:    :none
    },
    cusum_weekly: {
      name:             'Weekly CUSUM - divergence from modelled gas consumption',
      chart1_type:      :column,
      meter_definition: :allheat,
      series_breakdown: :cusum,
      timescale:        :year,
      x_axis:           :week,
      y2_axis:          :degreedays,
      yaxis_units:      :kwh,
      yaxis_scaling:    :none
    },
    cusum: {
      inherits_from:    :cusum_weekly,
      subtitle:         :daterange
    },
    baseload: {
      name:             'Baseload kW',
      chart1_type:      :line,
      series_breakdown: :baseload,
      meter_definition: :allelectricity,
      x_axis:           :day,
      x_axis_reformat:  { date: '%d-%m-%Y' },
      yaxis_units:      :kw,
      yaxis_scaling:    :none
    },
    baseload_lastyear: {
      name:             'Baseload kW - last year',
      timescale:        :up_to_a_year,
      inherits_from:    :baseload
    },
    peak_kw: {
      inherits_from:    :baseload,
      name:             'Peak daily power consumption (kW)',
      series_breakdown: :peak_kw
    },
    alert_1_year_baseload: {
      inherits_from:    :baseload_lastyear,
    },
    intraday_line_school_days:  {
      name:             'Intraday (school days) - comparison of last 2 years',
      chart1_type:      :line,
      series_breakdown: :none,
      timescale:        [{ year: 0 }, { year: -1 }],
      x_axis:           :intraday,
      meter_definition: :allelectricity,
      filter:           { daytype: [ Series::DayType::SCHOOLDAYOPEN, Series::DayType::SCHOOLDAYCLOSED ] },
      yaxis_units:      :kw,
      yaxis_scaling:    :none
    },
    intraday_line_school_days_last5weeks:  {
      name:             'Intraday (Last 5 weeks comparison - school day)',
      chart1_type:      :line,
      series_breakdown: :none,
      timescale:        [{ schoolweek: 0 }, { schoolweek: -1 }, { schoolweek: -2 }, { schoolweek: -3 }, { schoolweek: -4 }],
      x_axis:           :intraday,
      meter_definition: :allelectricity,
      filter:           { daytype: [ Series::DayType::SCHOOLDAYOPEN, Series::DayType::SCHOOLDAYCLOSED ] },
      yaxis_units:      :kw,
      yaxis_scaling:    :none
    },
    intraday_line_school_days_6months:  {
      name:             'Intraday (Comparison 6 months apart)',
      chart1_type:      :line,
      series_breakdown: :none,
      timescale:        [{ schoolweek: 0 }, { schoolweek: -20 }],
      x_axis:           :intraday,
      meter_definition: :allelectricity,
      filter:           { daytype: [ Series::DayType::SCHOOLDAYOPEN, Series::DayType::SCHOOLDAYCLOSED ] },
      yaxis_units:      :kw,
      yaxis_scaling:    :none
    },
    intraday_line_school_last7days:  {
      name:             'Intraday (last 7 days)',
      chart1_type:      :line,
      series_breakdown: :none,
      timescale:        [{ day: 0 }, { day: -1 }, { day: -2 }, { day: -3 }, { day: -4 }, { day: -5 }, { day: -6 }],
      x_axis:           :intraday,
      meter_definition: :allelectricity,
      yaxis_units:      :kw,
      yaxis_scaling:    :none
    },
    electricity_intraday_line_school_last7days_co2_commentary: {
      inherits_from: :intraday_line_school_last7days
    },
    electricity_intraday_line_school_last7days_carbon: {
      inherits_from:    :intraday_line_school_last7days,
      yaxis_units:      :co2,
      y2_axis:          :gridcarbon
    },
    intraday_line_school_days_reduced_data: {
      inherits_from:    :intraday_line_school_days,
      timescale:        [{ up_to_a_year: 0 }, { up_to_a_year: -1 }],
      ignore_single_series_failure: true
    },
    intraday_line_holidays:  {
      inherits_from:    :intraday_line_school_days_reduced_data,
      name:             'Intraday (holidays)',
      filter:           { daytype: [ Series::DayType::HOLIDAY] }
    },
    intraday_line_weekends:  {
      inherits_from:    :intraday_line_school_days_reduced_data,
      name:             'Intraday (weekends)',
      filter:           { daytype: [ Series::DayType::WEEKEND] },
    },
    group_by_week_electricity_dd: {
      name:             'By Week: Electricity',
      chart1_type:      :column,
      chart1_subtype:   :stacked,
      meter_definition: :allelectricity,
      x_axis:           :week,
      series_breakdown: :daytype,
      yaxis_units:      :kwh,
      yaxis_scaling:    :none,
      y2_axis:          :degreedays,
      timescale:        :year
    },

    frost:  {
      name:             'Frost Protection: cold weekend',
      chart1_type:      :column,
      series_breakdown: :none,
      timescale:        [{ frostday_3: 0 }], # 1 day either side of frosty day i.e. 3 days
      x_axis:           :datetime,
      meter_definition: :allheat,
      yaxis_units:      :kw,
      yaxis_scaling:    :none,
      y2_axis:          :temperature
    },
    frost_1:  {
      name:             'Frost Protection Example Sunday 1',
      inherits_from:    :frost,
      timescale:        [{ frostday_3: 0 }], # 1 day either side of frosty day i.e. 3 days
    },
    frost_2:  {
      name:             'Frost Protection Example Sunday 2',
      inherits_from:    :frost,
      timescale:        [{ frostday_3: -1 }], # 1 day either side of frosty day i.e. 3 days
    },
    frost_3:  {
      name:             'Frost Protection Example Sunday 3',
      inherits_from:    :frost,
      timescale:        [{ frostday_3: -2 }], # 1 day either side of frosty day i.e. 3 days
    },
    thermostatic_control_large_diurnal_range:  {
      name:             'Thermostatic Control Large Diurnal Range Assessment',
      chart1_type:      :column,
      series_breakdown: :none,
      timescale:        [{ diurnal: 0 }],
      x_axis:           :datetime,
      meter_definition: :allheat,
      yaxis_units:      :kw,
      yaxis_scaling:    :none,
      y2_axis:          :temperature
    },
    thermostatic_control_large_diurnal_range_1:  {
      name:             'Thermostatic Control Large Diurnal Range Assessment 1',
      inherits_from:    :thermostatic_control_large_diurnal_range,
      timescale:        [{ diurnal: 0 }],
    },
    thermostatic_control_large_diurnal_range_2:  {
      name:             'Thermostatic Control Large Diurnal Range Assessment 2',
      inherits_from:    :thermostatic_control_large_diurnal_range,
      timescale:        [{ diurnal: -1 }]
    },
    thermostatic_control_large_diurnal_range_3:  {
      name:             'Thermostatic Control Large Diurnal Range Assessment 3',
      inherits_from:    :thermostatic_control_large_diurnal_range,
      timescale:        [{ diurnal: -2 }]
    },
    thermostatic_control_medium_diurnal_range:  {
      name:             'Thermostatic Control Medium Diurnal Range Assessment',
      inherits_from:    :thermostatic_control_large_diurnal_range,
      timescale:        [{ diurnal: -20 }]
    },
    optimum_start:  {
      name:             'Optimum Start Control Check',
      chart1_type:      :line,
      series_breakdown: :none,
      timescale:        [
        { optimum_start:  0 },
        { optimum_start: -1 },
        { optimum_start: -2 },
        { optimum_start: -3 },
        { optimum_start: -4 }
      ],
      x_axis:           :intraday,
      meter_definition: :allheat,
      yaxis_units:      :kw,
      yaxis_scaling:    :none,
      y2_axis:          :temperature
    },
    boiler_start_time: {
      name:             'Boiler start time',
      chart1_type:      :line,
      series_breakdown: :boiler_start_time,
      meter_definition: :allheat,
      x_axis:           :day,
      x_axis_reformat:  { date: '%d-%m-%Y' },
      yaxis_units:      :boiler_start_time,
      yaxis_scaling:    :none,
      y2_axis:          :temperature
    },
    boiler_start_time_up_to_one_year: {
      name:             'Boiler start time: in last year',
      inherits_from:    :boiler_start_time,
      timescale:        :up_to_a_year
    },
    boiler_start_time_up_to_one_year_no_frost: {
      name:             'Boiler start time on non frosty mornings',
      inherits_from:    :boiler_start_time,
      boiler_start_time:  { ignore_frosty_days_temperature: 4.0 },
      timescale:        :up_to_a_year
    },
    hotwater: {
      name:             'Hot Water Analysis',
      chart1_type:      :column,
      chart1_subtype:   :stacked,
      series_breakdown: :hotwater,
      x_axis:           :day,
      meter_definition: :allheat,
      yaxis_units:      :kwh
    },
    hotwater_alert: {
      inherits_from:    :hotwater,
      yaxis_units:      :£
    },
    irradiance_test:  {
      name:             'Solar Irradiance Y2 axis check',
      inherits_from:    :optimum_start,
      y2_axis:          :irradiance
    },
    gridcarbon_test:  {
      name:             'Grid Carbon Y2 axis check',
      inherits_from:    :optimum_start,
      y2_axis:          :gridcarbon
    },
    last_2_weeks_gas_comparison: {
      name:             'Comparison of last 2 weeks gas consumption',
      chart1_type:      :column,
      series_breakdown: :none,
      x_axis_reformat:  { date: '%A' },
      timescale:        [{ schoolweek: 0 }, { schoolweek: -1 }],
      x_axis:           :day,
      meter_definition: :allheat,
      yaxis_units:      :kwh,
      yaxis_scaling:    :none,
      y2_axis:          :temperature
    },
    last_2_school_weeks_electricity_comparison_alert: {
      name:             'Comparison of last 2 school weeks electricity consumption',
      inherits_from:    :last_2_weeks_gas_comparison,
      meter_definition: :allelectricity,
      y2_axis:          :none
    },
    layerup_powerdown_11_november_2022_electricity_comparison_alert: {
      name:             '<%= meter.fuel_type.capitalize %> Comparison: Layer Up Powerdown Day 11 November 2022',
      inherits_from:    :last_2_school_weeks_electricity_comparison_alert,
      x_axis:           :day,
      timescale: [
        { daterange: Date.new(2021, 10, 12)..Date.new(2021, 10, 14) },
        { daterange: Date.new(2022, 10, 11)..Date.new(2022, 10, 13) }
      ],
      meter_definition: :allelectricity,
      y2_axis:          :none
    },
    layerup_powerdown_11_november_2022_gas_comparison_alert: {
      inherits_from:    :layerup_powerdown_11_november_2022_electricity_comparison_alert,
      meter_definition: :allheat
    },
    layerup_powerdown_11_november_2022_storage_heater_comparison_alert: {
      inherits_from:    :layerup_powerdown_11_november_2022_electricity_comparison_alert,
      meter_definition: :storage_heater_meter
    },
    autumn_term_2022_electricity_comparison_alert: {
      name:             '<%= meter.fuel_type.capitalize %> Comparison: Autumn Term 2022',
      inherits_from:    :last_2_school_weeks_electricity_comparison_alert,
      x_axis:           :day,
      timescale: [
        { daterange: Date.new(2021, 9, 6)..Date.new(2021, 12, 17) },
        { daterange: Date.new(2022, 9, 5)..Date.new(2022, 12, 16) }
      ],
      meter_definition: :allelectricity,
      y2_axis:          :none
    },
    autumn_term_2022_gas_comparison_alert: {
      inherits_from:    :layerup_powerdown_11_november_2022_electricity_comparison_alert,
      meter_definition: :allheat
    },
    autumn_term_2022_storage_heater_comparison_alert: {
      inherits_from:    :layerup_powerdown_11_november_2022_electricity_comparison_alert,
      meter_definition: :storage_heater_meter
    },
    recent_holiday_electricity_comparison_alert: {
      name:             'Comparison of electricity consumption for recent holidays',
      inherits_from:    :group_by_week_electricity,
      filter:           { daytype: [ Series::DayType::HOLIDAY ] },
      timescale:        { week: -10..0 }
    },
    alert_weekend_last_week_gas_datetime_kwh: {
      name:             'Last weeks half hourly gas consumption (kWh)',
      series_breakdown: :none,
      chart1_type:      :line,
      timescale:        :week,
      x_axis:           :datetime,
      meter_definition: :allheat,
      yaxis_units:      :kwh,
      yaxis_scaling:    :none,
      y2_axis:          :temperature
    },
    alert_weekend_last_week_gas_datetime_kw: {
      inherits_from:    :alert_weekend_last_week_gas_datetime_kwh,
      name:             'Last weeks half hourly gas consumption (kW)',
      yaxis_units:      :kw
    },
    alert_weekend_last_week_gas_datetime_£: {
      inherits_from:    :alert_weekend_last_week_gas_datetime_kwh,
      name:             'Last weeks half hourly gas consumption (£/half hour)',
      yaxis_units:      :£
    },
    alert_weekend_last_week_gas_datetime_£current: {
      inherits_from:    :alert_weekend_last_week_gas_datetime_£,
      yaxis_units:      :£current
    },
    last_2_weeks_gas: {
      name:             'Last 2 weeks gas consumption (with temperature)',
      timescale:        { week: -1..0 },
      x_axis_reformat:  nil,
      inherits_from:    :last_2_weeks_gas_comparison
    },
    last_2_weeks_gas_degreedays: {
      name:             'Last 2 weeks gas consumption (with degree days)',
      y2_axis:          :degreedays,
      timescale:        { week: -1..0 },
      x_axis_reformat:  nil,
      inherits_from:    :last_2_weeks_gas
    },
    last_2_weeks_gas_comparison_temperature_compensated: {
      name:             'Comparison of last 2 weeks gas consumption - adjusted for outside temperature',
      adjust_by_temperature:  10.0,
      y2_axis:          nil,
      inherits_from:    :last_2_weeks_gas_comparison
    },
    schoolweek_alert_2_week_comparison_for_internal_calculation_gas_unadjusted: {
      name:             'Comparison of last 2 weeks gas consumption - unadjusted alert calculation',
      y2_axis:          nil,
      inherits_from:    :last_2_weeks_gas_comparison
    },
    schoolweek_alert_2_week_comparison_for_internal_calculation_gas_adjusted: {
      name:                   'Comparison of last 2 weeks gas consumption - temperature adjusted alert calculation',
      adjust_by_temperature:  { schoolweek: 0 },

      #asof_date:              Date.new(2019, 3, 7), # gets overridden by alert
      inherits_from:          :schoolweek_alert_2_week_comparison_for_internal_calculation_gas_unadjusted
    },
    schoolweek_alert_2_week_comparison_for_internal_calculation_storage_heater_adjusted: {
      inherits_from:          :schoolweek_alert_2_week_comparison_for_internal_calculation_gas_adjusted,
      meter_definition: :storage_heater_meter
    },
    schoolweek_alert_2_week_comparison_for_internal_calculation_storage_heater_unadjusted: {
      inherits_from:          :schoolweek_alert_2_week_comparison_for_internal_calculation_gas_unadjusted,
      meter_definition: :storage_heater_meter
    },
    schoolweek_alert_2_previous_holiday_comparison_gas_adjusted: {
      name:                           'Comparison of last 2 weeks gas consumption - temperature adjusted alert calculation',
      adjust_by_average_temperature:  { holiday: 0 },
      #asof_date:                     Date.new(2019, 3, 7), # gets overridden by alert
      inherits_from:                  :schoolweek_alert_2_week_comparison_for_internal_calculation_gas_unadjusted
    },
    schoolweek_alert_2_week_comparison_for_internal_calculation_gas_unadjusted_community_only: {
      name:           'Comparison of last 2 weeks gas consumption - temperature unadjusted alert calculation, community use only',
      community_use:  { filter: :community_only, aggregate: :all_to_single_value },
      inherits_from:  :schoolweek_alert_2_week_comparison_for_internal_calculation_gas_unadjusted
    },
    schoolweek_alert_2_week_comparison_for_internal_calculation_gas_adjusted_community_only: {
      name:           'Comparison of last 2 weeks gas consumption - temperature adjusted alert calculation, community use only',
      community_use:  { filter: :community_only, aggregate: :all_to_single_value },
      inherits_from:  :schoolweek_alert_2_week_comparison_for_internal_calculation_gas_adjusted
    },
    teachers_landing_page_gas: {
      timescale:        [{ workweek: 0 }, { workweek: -1 }],
      yaxis_units:      :£,
      inherits_from:    :last_2_weeks_gas_comparison_temperature_compensated
    },
    teachers_landing_page_gas_simple: {
      yaxis_units:      :£,
      y2_axis:          nil,
      inherits_from:    :last_2_weeks_gas_comparison
    },
    teachers_landing_page_storage_heaters: {
      inherits_from:    :teachers_landing_page_gas,
      meter_definition: :storage_heater_meter
    },
    teachers_landing_page_storage_heaters_simple: {
      inherits_from:    :teachers_landing_page_gas_simple,
      meter_definition: :storage_heater_meter
    },
    alert_last_2_weeks_gas_comparison_temperature_compensated: {
      inherits_from:    :last_2_weeks_gas_comparison_temperature_compensated
    },
    teachers_landing_page_electricity: {
      name:             'Comparison of last 2 weeks electricity consumption',
      meter_definition: :allelectricity,
      inherits_from:    :teachers_landing_page_gas
    },
    adult_dashboard_drilldown_last_2_weeks_electricity_comparison: {
      name:             'Comparison of last 2 school weeks electricity consumption',
      inherits_from:    :teachers_landing_page_electricity,
      timescale:        [{ schoolweek: 0 }, { schoolweek: -1 }],
    },
    alert_week_on_week_electricity_daily_electricity_comparison_chart: {
      # used by short term change alert
      inherits_from:    :teachers_landing_page_electricity
    },
    alert_intraday_line_school_days_last5weeks: {
      inherits_from:    :intraday_line_school_days_last5weeks
    },
    alert_intraday_line_school_last7days: {
      inherits_from:    :intraday_line_school_days_last5weeks
    },
    last_4_weeks_gas_temperature_compensated: {
      name:             'Last 4 weeks gas consumption - adjusted for outside temperature',
      adjust_by_temperature:  10.0,
      timescale:        [{ day: -27...0 }],
      y2_axis:          nil,
      x_axis_reformat:  nil,
      inherits_from:    :last_2_weeks_gas_comparison
    },
    last_7_days_intraday_gas:  {
      inherits_from:    :intraday_line_school_last7days,
      name:             'Intraday (last 7 days) gas',
      meter_definition: :allheat
    },
    alert_last_7_days_intraday_gas_heating_on_too_early: {
      inherits_from:    :last_7_days_intraday_gas
    },
    calendar_picker_gas_week_chart: {
      name:             'Calendar picker gas week chart',
      chart1_type:      :column,
      chart1_subtype:   :stacked,
      series_breakdown: :daytype,
      timescale:        { daterange: Date.new(2018,6,12)..Date.new(2018,6,18) },
      x_axis:           :day,
      x_axis_reformat:  { date: '%a %d %b %Y' },
      meter_definition: :allheat,
      yaxis_units:      :kwh,
      yaxis_scaling:    :none
    },
    calendar_picker_electricity_week_chart: {
      name:             'Calendar picker electricity week chart',
      meter_definition: :allelectricity,
      inherits_from:    :calendar_picker_gas_week_chart
    },
    calendar_picker_storage_heaters_week_chart: {
      name:             'Calendar picker storage heaters week chart',
      meter_definition: :storage_heater_meter,
      inherits_from:    :calendar_picker_gas_week_chart
    },
    calendar_picker_gas_day_chart: {
      name:             'Calendar picker gas day chart',
      chart1_type:      :line,
      series_breakdown: :none,
      timescale:        { daterange: Date.new(2018,6,12)..Date.new(2018,6,12) },
      x_axis:           :intraday,
      meter_definition: :allheat,
      yaxis_units:      :kw,
      yaxis_scaling:    :none
    },
    calendar_picker_electricity_day_chart: {
      name:             'Calendar picker electricity day chart',
      meter_definition: :allelectricity,
      inherits_from:    :calendar_picker_gas_day_chart
    },
    calendar_picker_storage_heater_day_chart: {
      name:             'Calendar picker storage heater day chart',
      meter_definition: :storage_heater_meter,
      inherits_from:    :calendar_picker_gas_day_chart
    },
    calendar_picker_electricity_week_example_comparison_chart: {
      name:             'Calendar picker electricity example week comparison chart',
      timescale:        [
                          { daterange: Date.new(2019,9,1)..Date.new(2019,9,7)  },
                          { daterange: Date.new(2019,9,8)..Date.new(2019,9,14) },
                        ],
      chart1_subtype:   nil,
      series_breakdown: :none,
      x_axis_reformat:  { date: '%A' },
      calendar_picker_allow_up_to_1_week_past_last_meter_date: true,
      inherits_from:    :calendar_picker_electricity_week_chart
    },
    public_displays_electricity_weekly_comparison: {
      name:             'Public displays weekly electricity comparison',
      chart1_type:      :column,
      chart1_subtype:   nil,
      meter_definition: :allelectricity,
      series_breakdown: :none,
      timescale:        [{ week: 0  }, { week: -1 }],
      x_axis:           :day,
      x_axis_reformat:  { date: '%A' },
      yaxis_units:      :kwh,
      yaxis_scaling:    :none
    },
    public_displays_gas_weekly_comparison: {
      name:             'Public displays weekly electricity comparison',
      inherits_from:    :public_displays_electricity_weekly_comparison,
      meter_definition: :allheat
    },
    calendar_picker_electricity_day_example_comparison_chart: {
      name:             'Calendar picker electricity example day comparison chart',
      timescale:        [
                          { daterange: Date.new(2018,6,12)..Date.new(2018,6,12) },
                          { daterange: Date.new(2018,6,13)..Date.new(2018,6,13) },
                        ],
      chart1_subtype:   nil,
      series_breakdown: :none,
      inherits_from:    :calendar_picker_electricity_day_chart
    },
    calendar_picker_gas_week_example_comparison_chart: {
      name:             'Calendar picker gas example week comparison chart',
      inherits_from:    :calendar_picker_electricity_week_example_comparison_chart,
      meter_definition: :allheat
    },
    calendar_picker_gas_day_example_comparison_chart: {
      name:             'Calendar picker gas example day comparison chart',
      inherits_from:    :calendar_picker_electricity_day_example_comparison_chart,
      meter_definition: :allheat
    },
    calendar_picker_electricity_day_example_meter_breakdown_chart: {
      name:             'Calendar picker electricity example meter breakdown chart',
      series_breakdown: :meter,
      inherits_from:    :calendar_picker_electricity_week_chart
    },
    calendar_picker_electricity_day_example_meter_breakdown_comparison_chart: {
      name:             'Calendar picker electricity example meter breakdown chart',
      series_breakdown: :meter,
      timescale:        [
        { daterange: Date.new(2018,6,12)..Date.new(2018,6,18) },
        { daterange: Date.new(2018,6,19)..Date.new(2018,6,26) },
      ],
      inherits_from:    :calendar_picker_electricity_week_chart
    },
    #======================================PUPIL DASHBOARD - ELECTRICITY=============================================
    pupil_dashboard_group_by_week_electricity_kwh: {
      name:             'Your school\'s electricity use over a year (in kWh). Each bar shows a week\'s use',
      drilldown_name:   ['Electricity use in your chosen week (in kWh)', 'Electricity use on your chosen day (in kWh)'],
      inherits_from:    :group_by_week_electricity,
      minimum_days_data_override: 21
    },
    pupil_dashboard_group_by_week_electricity_£: {
      name:             'Your school\'s electricity costs over a year (in £). Each bar shows a week\'s costs.',
      drilldown_name:   ['Electricity costs in your chosen week (in £)', 'Electricity costs on your chosen day (in £)'],
      inherits_from:    :pupil_dashboard_group_by_week_electricity_kwh,
      yaxis_units:      :£
    },
    pupil_dashboard_group_by_week_electricity_co2: {
      name:             'Your school\'s carbon emissions from electricity use over a year (in kg CO2). Each bar shows a week\'s emissions.',
      drilldown_name:   ['Electricity carbon emissions in your chosen week (in kg CO2)', 'Electricity carbon emissions on your chosen day (in kg CO2)'],
      inherits_from:  :pupil_dashboard_group_by_week_electricity_kwh,
      yaxis_units:      :co2
    },
    pupil_dashboard_electricity_benchmark: {
      name:               'How much my school spends on electricity in comparison with other schools (£)',
      inherits_from:      :benchmark,
      restrict_y1_axis:   nil,
      meter_definition:   :allelectricity
    },
    pupil_dashboard_electricity_longterm_trend_£: {
      name:             'Your school\'s long term electricity costs (£). Each bar shows a year\'s costs.',
      drilldown_name:   [
        'Your school\'s electricity costs over a year (in £). Each bar shows a week\'s costs.',
        'Electricity costs in your chosen week (in £)',
        'Electricity costs on your chosen day (in £)'
      ],
      inherits_from:     :electricity_longterm_trend,
      yaxis_units:      :£
    },
    pupil_dashboard_daytype_breakdown_electricity: {
      name:             'When your school used electricity over the past year. School day closed is the electricity used in the evenings and early mornings during term time.',
      timescale:        :year,
      inherits_from:     :daytype_breakdown_electricity,
      minimum_days_data_override: 180
    },
    pupil_dashboard_baseload_lastyear: {
      name:             'Your school\'s electricity baseload. This is power used when the school is empty (kW)',
      inherits_from:     :baseload_lastyear,
      drilldown_name:   ['Electricity power consumption on your chosen day (in kW)'],
      minimum_days_data_override: 21
    },
    pupil_dashboard_intraday_line_electricity_last7days: {
      name:             'Your school\'s electricity use over 7 days (kW)',
      inherits_from:     :intraday_line_school_last7days
    },
    #======================================PUPIL DASHBOARD - GAS=============================================
    pupil_dashboard_group_by_week_gas_kwh: {
      name:             'Your school\'s gas use over a year (in kWh). Each bar shows a week\'s use.',
      drilldown_name:   ['Gas use in your chosen week (in kWh)', 'Gas use on your chosen day (in kWh)'],
      inherits_from:    :pupil_dashboard_group_by_week_electricity_kwh,
      meter_definition: :allheat
    },
    pupil_dashboard_group_by_week_gas_£: {
      name:             'Your school\'s gas costs over a year (in £). Each bar shows a week\'s costs.',
      drilldown_name:   ['Gas costs in your chosen week (in £)', 'Gas costs on your chosen day (in £)'],
      inherits_from:    :pupil_dashboard_group_by_week_gas_kwh,
      yaxis_units:      :£
    },
    pupil_dashboard_group_by_week_gas_co2: {
      name:             'Your school\'s carbon emissions from gas use over a year (in kg CO2). Each bar shows a week\'s emissions.',
      drilldown_name:   ['Gas carbon emissions in your chosen week (in kg CO2)', 'Gas carbon emissions on your chosen day (in kg CO2)'],
      inherits_from:  :pupil_dashboard_group_by_week_gas_kwh,
      yaxis_units:      :co2
    },
    pupil_dashboard_gas_benchmark: {
      name:             'How much my school spends on gas in comparison with other schools (£)',
      inherits_from:      :pupil_dashboard_electricity_benchmark,
      restrict_y1_axis:   nil,
      meter_definition:   :allheat
    },
    pupil_dashboard_daytype_breakdown_gas: {
      name:              'When your school used gas over the past year. School day closed is the gas used in the evenings and early mornings during term time.',
      inherits_from:     :pupil_dashboard_daytype_breakdown_electricity,
      meter_definition:  :allheat
    },
    pupil_dashboard_gas_longterm_trend_£: {
      name:             'Your school\'s long term gas costs (£). Each bar shows a year\'s costs.',
      drilldown_name:   [
        'Your school\'s gas costs over a year (in £). Each bar shows a week\'s costs.',
        'Gas costs in your chosen week (in £)',
        'Gas costs on your chosen day (in £)'
      ],
      inherits_from:     :pupil_dashboard_electricity_longterm_trend_£,
      meter_definition:  :allheat
    },
    pupil_dashboard_intraday_line_gas_last7days: {
      name:             'Your school\'s gas use over 7 days (kW)',
      inherits_from:     :pupil_dashboard_intraday_line_electricity_last7days,
      meter_definition:  :allheat
    },
    #======================================PUPIL DASHBOARD - STORAGE HEATERS========================================
    pupil_dashboard_group_by_week_storage_heaters_kwh: {
      name:             'Your school\'s storage heater use over a year (in kWh). Each bar shows a week\'s use.',
      drilldown_name:   ['Storage heater use in your chosen week (in kWh)', 'Storage heater use on your chosen day (in kWh)'],
      inherits_from:    :pupil_dashboard_group_by_week_electricity_kwh,
      meter_definition: :storage_heater_meter
    },
    pupil_dashboard_group_by_week_storage_heaters_£: {
      name:             'Your school\'s storage heater costs over a year (in £). Each bar shows a week\'s costs.',
      drilldown_name:   ['Storage heater costs in your chosen week (in £)', 'Storage heater costs on your chosen day (in £)'],
      inherits_from:    :pupil_dashboard_group_by_week_storage_heaters_kwh,
      yaxis_units:      :£
    },
    pupil_dashboard_group_by_week_storage_heaters_co2: {
      name:             'Your school\'s carbon emissions from storage heater use over a year (in kg CO2). Each bar shows a week\'s emissions.',
      drilldown_name:   ['Storage heater carbon emissions in your chosen week (in kg CO2)', 'Storage heater carbon emissions on your chosen day (in kg CO2)'],
      inherits_from:    :pupil_dashboard_group_by_week_storage_heaters_kwh,
      yaxis_units:      :co2
    },
    pupil_dashboard_storage_heaters_benchmark: {
      name:             'How much my school spends on storage heating in comparison with other schools (£)',
      inherits_from:      :pupil_dashboard_electricity_benchmark,
      restrict_y1_axis:   nil,
      meter_definition:   :storage_heater_meter
    },
    pupil_dashboard_daytype_breakdown_storage_heaters: {
      name:              'When your school used storage heaters over the past year. School day closed is the storage heaters used in the evenings and early mornings during term time.',
      inherits_from:     :pupil_dashboard_daytype_breakdown_electricity,
      meter_definition:  :storage_heater_meter
    },
    pupil_dashboard_storage_heaters_longterm_trend_£: {
      name:             'Your school\'s long term storage heaters costs (£). Each bar shows a year\'s costs.',
      drilldown_name:   [
        'Your school\'s storage heaters costs over a year (in £). Each bar shows a week\'s costs.',
        'Storage heater costs in your chosen week (in £)',
        'Storage heater costs on your chosen day (in £)'
      ],
      inherits_from:     :pupil_dashboard_electricity_longterm_trend_£,
      meter_definition:  :storage_heater_meter
    },
    pupil_dashboard_intraday_line_storage_heaters_last7days: {
      name:             'Your school\'s storage heaters use over 7 days (kW)',
      inherits_from:     :pupil_dashboard_intraday_line_electricity_last7days,
      meter_definition:  :storage_heater_meter
    },
    #======================================PUPIL DASHBOARD - SOLAR PV========================================
    pupil_dashboard_solar_pv_benchmark: {
      name:               'How much my school spends on electricity in comparison with other schools (£)',
      inherits_from:      :pupil_dashboard_electricity_benchmark
    },
    pupil_dashboard_solar_pv_monthly: {
      name:               'How my school\'s solar PV panels reduce my school\'s mains electricity consumption (kWh)',
      drilldown_name:   [
        'Impact of Solar PV in your chosen month (in kWh)',
        'Impact of Solar PV on your chosen day (in kWh)'
      ],
      inherits_from:      :solar_pv_group_by_month_dashboard_overview
    },
    stacked_all_years:  {
      name:             'Stacked bar chart, all years of data',
      chart1_type:      :bar,
      chart1_subtype:   :stacked,
      meter_definition: :all,
      x_axis:           :year,
      series_breakdown: :fuel,
      yaxis_units:      :£,
      restrict_y1_axis: [:£, :co2],
      yaxis_scaling:    :none
    }
  }.freeze
end
