require_relative './benchmark_content_base.rb'
require_relative './benchmark_content_general.rb'
require_relative '../alerts/common/management_summary_table.rb'

module Benchmarking

  class BenchmarkManager
    def self.chart_table_config(name)
      CHART_TABLE_CONFIG[name]
    end

    def self.chart_column?(column_definition)
      y1_axis_column?(column_definition) || y2_axis_column?(column_definition)
    end

    def self.y1_axis_column?(column_definition)
      column_definition?(column_definition, :chart_data) && !y2_axis_column?(column_definition)
    end

    def self.y2_axis_column?(column_definition)
      column_definition?(column_definition, :y2_axis)
    end

    def self.has_y2_column?(definition)
      definition[:columns].any? { |column_definition| y2_axis_column?(column_definition) }
    end

    def self.column_definition?(column_definition, key)
      column_definition.key?(key) && column_definition[key]
    end

    def self.structured_pages(user_type_hash = { user_role: :guest }, _filter_out = nil)
      user_role = user_type_hash[:user_role] || :guest

      CHART_TABLE_GROUPING.each_with_object([]) do |(group_key, benchmark_keys), structured_pages|
        structured_page = structured_page_for(group_key, benchmark_keys, user_role)
        next unless structured_page
        structured_pages << structured_page
      end
    end

    def self.structured_page_for(group_key, benchmark_keys, user_role)
      benchmarks = benchmark_titles_for(benchmark_keys, user_role)
      return if benchmarks.empty?

      {
        name: I18n.t("analytics.benchmarking.chart_table_grouping.#{group_key}.title"),
        description: I18n.t("analytics.benchmarking.chart_table_grouping.#{group_key}.description"),
        benchmarks: benchmark_titles_for(benchmark_keys, user_role)
      }
    end

    def self.benchmark_titles_for(benchmark_keys, user_role)
      benchmark_keys.each_with_object({}) do |benchmark_key, benchmarks|
        next if CHART_TABLE_CONFIG[benchmark_key][:admin_only] == true && [:admin, :analyst].exclude?(user_role)

        benchmarks[benchmark_key] = I18n.t("analytics.benchmarking.chart_table_config.#{benchmark_key}")
      end
    end

    def self.available_pages(filter_out = nil)
      all_pages = CHART_TABLE_CONFIG.clone
      all_pages = all_pages.select{ |name, config| !filter_out?(config, filter_out.keys[0], filter_out.values[0]) } unless filter_out.nil?
      all_pages.transform_values{ |config| config[:name] }
    end

    def self.filter_out?(config, key, value)
      config.key?(key) && config[key] == value
    end

    # complex sort, so schools with missing meters, compare
    # their fuel type only and not on a total basis
    def self.sort_energy_costs(row1, row2)
      # row = [name, electric, gas, storage heaters, etc.....]
      row1a = [row1[1], [row1[2], row1[3]].compact.sum] # combined gas and storage heaters
      row2a = [row2[1], [row2[2], row2[3]].compact.sum]
      return  0 if row1a.compact.empty? && row2a.compact.empty?
      return +1 if row2a.compact.empty?
      return -1 if row1a.compact.empty?
      if row1a.compact.length == row2a.compact.length
        row1a.compact.sum <=> row2a.compact.sum
      elsif row1a[0].nil? || row2a[0].nil? # compare [nil, val] with [val1, val2] => val <=> val2
        row1a[1] <=> row2a[1]
      else                # compare [val, nil] with [val1, val2] => val <=> val1
        row1a[0] <=> row2a[0]
      end
    end

    def self.sort_by_nil(row1, row2)
      if row1[3].nil? && row2[3].nil?
        row1[2] <=> row2[2] # sort by this year kWh
      else
        nil_to_infinity(row1[3]) <=> nil_to_infinity(row2[3])
      end
    end

    def self.nil_to_infinity(val)
      val.nil? ? Float::INFINITY : val
    end

    CHART_TABLE_GROUPING = {
      total_energy_use_benchmarks: [
        :annual_energy_costs_per_pupil,
        :annual_energy_costs,
        :annual_energy_costs_per_floor_area,
        :change_in_energy_since_last_year,
        :holiday_usage_last_year
      ],
      electricity_benchmarks: [
        :change_in_electricity_since_last_year,
        :annual_electricity_costs_per_pupil,
        :annual_electricity_out_of_hours_use,
        :recent_change_in_baseload,
        :baseload_per_pupil,
        :seasonal_baseload_variation,
        :weekday_baseload_variation,
        :electricity_peak_kw_per_pupil,
        :electricity_targets,
        :change_in_electricity_consumption_recent_school_weeks,
        :change_in_electricity_holiday_consumption_previous_holiday,
        :change_in_electricity_holiday_consumption_previous_years_holiday,
        :electricity_consumption_during_holiday,
        :annual_change_in_electricity_out_of_hours_use
      ],
      gas_and_storage_heater_benchmarks: [
        :change_in_gas_since_last_year,
        :change_in_storage_heaters_since_last_year,
        :annual_heating_costs_per_floor_area,
        :annual_gas_out_of_hours_use,
        :annual_storage_heater_out_of_hours_use,
        :heating_coming_on_too_early,
        :thermostat_sensitivity,
        :heating_in_warm_weather,
        :thermostatic_control,
        :hot_water_efficiency,
        :gas_targets,
        :change_in_gas_consumption_recent_school_weeks,
        :change_in_gas_holiday_consumption_previous_holiday,
        :change_in_gas_holiday_consumption_previous_years_holiday,
        :gas_consumption_during_holiday,
        :storage_heater_consumption_during_holiday,
        :annual_change_in_gas_out_of_hours_use,
        :annual_change_in_storage_heater_out_of_hours_use
      ],
      solar_benchmarks: [
        :change_in_solar_pv_since_last_year,
        :solar_pv_benefit_estimate,
        :solar_generation_summary
      ],
      date_limited_comparisons: [
        :change_in_energy_use_since_joined_energy_sparks,
        :jan_august_2022_2023_energy_comparison,
        :layer_up_powerdown_day_november_2023,
        :heat_saver_march_2024
      ]
    }

    def self.tariff_changed_school_name(content_class = nil)
      if content_class.nil?
        { data: ->{ tariff_change_reference(addp_name, addp_etch || addp_gtch)}, name: :name, units: String, chart_data: true }
      else
        { data: ->{ tariff_change_reference(addp_name, addp_etch || addp_gtch)}, name: :name, units: String, chart_data: true, content_class: content_class }
      end
    end

    def self.tariff_changed_between_periods(changed)
      { data: changed, name: :tariff_changed_period, units: TrueClass, hidden: true }
    end

    TARIFF_CHANGED_COL        = { data: ->{ addp_etch || addp_gtch }, name: :tariff_changed, units: TrueClass, hidden: true }

    def self.blended_baseload_rate_col(variable)
      { data: variable, name: :blended_current_rate, units: :£_per_kwh, hidden: true }
    end

    CHART_TABLE_CONFIG = {
      annual_energy_costs_per_pupil: {
        benchmark_class:  BenchmarkContentEnergyPerPupil,
        name:     'Annual energy use per pupil',
        columns:  [
          tariff_changed_school_name('AdviceBenchmark'),
          { data: ->{ elba_kpup },          name: :last_year_electricity_kwh_pupil, units: :kwh, chart_data: true },
          { data: ->{ gsba_kpup },          name: :last_year_gas_kwh_pupil, units: :kwh, chart_data: true },
          { data: ->{ shan_kpup },          name: :last_year_storage_heater_kwh_pupil, units: :kwh, chart_data: true },
          { data: ->{ sum_data([elba_kpup, gsba_kpup, shan_kpup]) }, name: :last_year_energy_kwh_pupil, units: :kwh},
          { data: ->{ sum_data([elba_£pup, gsba_£pup, shan_£pup]) }, name: :last_year_energy_£_pupil, units: :£},
          { data: ->{ sum_data([elba_cpup, gsba_cpup, shan_cpup]) }, name: :last_year_energy_kgco2_pupil, units: :kwh},
          { data: ->{ addp_stpn },          name: :type,   units: String },
          { data: ->{ enba_ratg },          name: :rating, units: Float, y2_axis: true },
          TARIFF_CHANGED_COL
        ],
        where:   ->{ !enba_kpup.nil? },
        sort_by:  method(:sort_energy_costs),
        type: %i[chart table],
        drilldown:  { type: :adult_dashboard, content_class: 'AdviceBenchmark' },
        admin_only: false,
        column_heading_explanation: :last_year_definition_html
      },
      annual_energy_costs: {
        benchmark_class:  BenchmarkContentTotalAnnualEnergy,
        name:     'Annual energy costs',
        columns:  [
          { data: 'addp_name',              name: :name, units: String, chart_data: true },
          { data: ->{ elba_£lyr },          name: :last_year_electricity_£, units: :£, chart_data: true },
          { data: ->{ gsba_£lyr },          name: :last_year_gas_£, units: :£, chart_data: true },
          { data: ->{ shan_£lyr },          name: :last_year_storage_heater_£, units: :£, chart_data: true },
          { data: ->{ enba_£lyr },          name: :total_energy_costs_£, units: :£},
          { data: ->{ enba_£pup },          name: :last_year_energy_£_pupil, units: :£},
          { data: ->{ enba_co2t },          name: :last_year_energy_co2tonnes, units: :co2 },
          { data: ->{ enba_klyr },          name: :last_year_energy_kwh, units: :kwh },
          { data: ->{ addp_stpn },          name: :type,   units: String  },
          { data: ->{ addp_pupn },          name: :pupils, units: :pupils },
          { data: ->{ addp_flra },          name: :floor_area, units: :m2 },
        ],
        sort_by:  [4],
        type: %i[chart table],
        admin_only: false,
        column_heading_explanation: :last_year_definition_html
      },
      annual_energy_costs_per_floor_area: {
        benchmark_class:  BenchmarkContentEnergyPerFloorArea,
        name:     'Annual energy use per floor area',
        columns:  [
          { data: 'addp_name',      name: :name, units: String, chart_data: true },
          { data: ->{ enba_£fla },  name: :last_year_energy_£_floor_area, units: :£, chart_data: true },
          { data: ->{ enba_£lyr },  name: :last_year_energy_cost_£, units: :£},
          { data: ->{ enba_ratg },  name: :rating, units: Float, y2_axis: true },
        ],
        sort_by:  [1],
        type: %i[chart table],
        admin_only: false,
        column_heading_explanation: :last_year_definition_html
      },
      change_in_energy_use_since_joined_energy_sparks: {
        benchmark_class:  BenchmarkContentChangeInEnergyUseSinceJoined,
        name:     'Change in energy use since the school joined Energy Sparks',
        columns:  [
          { data: 'addp_name',      name: :name, units: :school_name, chart_data: true },
          { data: ->{ addp_sact },  name: :energy_sparks_join_date, units: :date_mmm_yyyy },
          { data: ->{ enba_kxap },  name: :energy_total,   units: :relative_percent_0dp, chart_data: true, content_class: 'AdviceBenchmark' },
          { data: ->{ enba_keap },  name: :electricity,      units: :relative_percent_0dp },
          { data: ->{ enba_kgap },  name: :gas,              units: :relative_percent_0dp },
          { data: ->{ enba_khap },  name: :storage_heaters,  units: :relative_percent_0dp },
          { data: ->{ enba_ksap },  name: :solar_pv,         units: :relative_percent_0dp }
        ],
        column_groups: [
          { name: '',                                     span: 2 },
          { name: :change_since_joined_energy_sparks,    span: 5 },
        ],
        treat_as_nil:   [ManagementSummaryTable::NO_RECENT_DATA_MESSAGE, ManagementSummaryTable::NOT_ENOUGH_DATA_MESSAGE], # from ManagementSummaryTable:: not referenced because not on path
        sort_by:  [2],
        type: %i[chart table],
        admin_only: true
      },
      layer_up_powerdown_day_november_2022: {
        benchmark_class:  BenchmarkChangeAdhocComparison,
        name:       'Change in energy for layer up power down day 11 November 2022 (compared with 12 Nov 2021)',
        columns:  [
          { data: 'addp_name', name: :name, units: :school_name, chart_data: true},

          # kWh

          { data: ->{ sum_if_complete([lue1_pppk, lug1_pppk, lus1_pppk], [lue1_cppk, lug1_cppk, lus1_cppk]) }, name: :previous_year, units: :kwh },
          { data: ->{ sum_data([lue1_cppk, lug1_cppk, lus1_cppk]) },                                name: :last_year,  units: :kwh },
          {
            data: ->{ percent_change(
                                      sum_if_complete([lue1_pppk, lug1_pppk, lus1_pppk], [lue1_cppk, lug1_cppk, lus1_cppk]),
                                      sum_data([lue1_cppk, lug1_cppk, lus1_cppk]),
                                      true
                                    ) },
            name: :change_pct, units: :relative_percent_0dp
          },

          # CO2
          { data: ->{ sum_if_complete([lue1_pppc, lug1_pppc, lus1_pppc], [lue1_cppc, lug1_cppc, lus1_cppc]) }, name: :previous_year, units: :co2 },
          { data: ->{ sum_data([lue1_cppc, lug1_cppc, lus1_cppc]) },                                name: :last_year,  units: :co2 },
          {
            data: ->{ percent_change(
                                      sum_if_complete([lue1_pppc, lug1_pppc, lus1_pppc], [lue1_cppc, lug1_cppc, lus1_cppc]),
                                      sum_data([lue1_cppc, lug1_cppc, lus1_cppc]),
                                      true
                                    ) },
            name: :change_pct, units: :relative_percent_0dp
          },

          # £

          { data: ->{ sum_if_complete([lue1_ppp£, lug1_ppp£, lus1_ppp£], [lue1_cpp£, lug1_cpp£, lus1_cpp£]) }, name: :previous_year, units: :£ },
          { data: ->{ sum_data([lue1_cpp£, lug1_cpp£, lus1_cpp£]) },                                name: :last_year,  units: :£ },
          {
            data: ->{ percent_change(
                                      sum_if_complete([lue1_ppp£, lug1_ppp£, lus1_ppp£], [lue1_cpp£, lug1_cpp£, lus1_cpp£]),
                                      sum_data([lue1_cpp£, lug1_cpp£, lus1_cpp£]),
                                      true
                                    ) },
            name: :change_£, units: :relative_percent_0dp, chart_data: true
          },

          # Metering

          { data: ->{
              [
                lue1_ppp£.nil? ? nil : :electricity,
                lug1_ppp£.nil? ? nil : :gas,
                lus1_ppp£.nil? ? nil : :storage_heaters
              ].compact.join(', ')
            },
            name: :metering,
            units: String
          },
        ],
        column_groups: [
          { name: '',         span: 1 },
          { name: :kwh,       span: 3 },
          { name: :co2_kg,    span: 3 },
          { name: :cost,      span: 3 },
          { name: '',         span: 1 }
        ],
        where:   ->{ !sum_data([lue1_ppp£, lug1_ppp£, lus1_ppp£], true).nil? },
        sort_by:  [9],
        type: %i[chart table],
        admin_only: true,
        column_heading_explanation: :last_year_previous_year_definition_html
      },
      autumn_term_2021_2022_energy_comparison: {
        benchmark_class:  BenchmarkAutumn2022Comparison,
        name:       'Autumn Term 2021 versus 2022 energy use comparison',
        columns:  [
          tariff_changed_school_name,

          # kWh

          { data: ->{ sum_if_complete([a22e_pppk, a22g_pppk, a22s_pppk], [a22e_cppk, a22g_cppk, a22s_cppk]) }, name: :previous_year, units: :kwh },
          { data: ->{ sum_data([a22e_cppk, a22g_cppk, a22s_cppk]) },                                name: :last_year,  units: :kwh },
          {
            data: ->{ percent_change(
                                      sum_if_complete([a22e_pppk, a22g_pppk, a22s_pppk], [a22e_cppk, a22g_cppk, a22s_cppk]),
                                      sum_data([a22e_cppk, a22g_cppk, a22s_cppk]),
                                      true
                                    ) },
            name: :change_pct, units: :relative_percent_0dp
          },

          # CO2
          { data: ->{ sum_if_complete([a22e_pppc, a22g_pppc, a22s_pppc], [a22e_cppc, a22g_cppc, a22s_cppc]) }, name: :previous_year, units: :co2 },
          { data: ->{ sum_data([a22e_cppc, a22g_cppc, a22s_cppc]) },                                name: :last_year,  units: :co2 },
          {
            data: ->{ percent_change(
                                      sum_if_complete([a22e_pppc, a22g_pppc, a22s_pppc], [a22e_cppc, a22g_cppc, a22s_cppc]),
                                      sum_data([a22e_cppc, a22g_cppc, a22s_cppc]),
                                      true
                                    ) },
            name: :change_pct, units: :relative_percent_0dp
          },

          # £

          { data: ->{ sum_if_complete([a22e_ppp£, a22g_ppp£, a22s_ppp£], [a22e_cpp£, a22g_cpp£, a22s_cpp£]) }, name: :previous_year, units: :£ },
          { data: ->{ sum_data([a22e_cpp£, a22g_cpp£, a22s_cpp£]) },                                name: :last_year,  units: :£ },
          {
            data: ->{ percent_change(
                                      sum_if_complete([a22e_ppp£, a22g_ppp£, a22s_ppp£], [a22e_cpp£, a22g_cpp£, a22s_cpp£]),
                                      sum_data([a22e_cpp£, a22g_cpp£, a22s_cpp£]),
                                      true
                                    ) },
            name: :change_£, units: :relative_percent_0dp, chart_data: true
          },

          # Metering

          { data: ->{
              [
                a22e_ppp£.nil? ? nil : :electricity,
                a22g_ppp£.nil? ? nil : :gas,
                a22s_ppp£.nil? ? nil : :storage_heaters
              ].compact.join(', ')
            },
            name: :metering,
            units: String
          },
          TARIFF_CHANGED_COL
        ],
        column_groups: [
          { name: '',         span: 1 },
          { name: :kwh,      span: 3 },
          { name: :co2_kg, span: 3 },
          { name: :cost,     span: 3 },
          { name: '',         span: 1 }
        ],
        where:   ->{ !sum_data([a22e_ppp£, a22g_ppp£, a22s_ppp£], true).nil? },
        sort_by:  [9],
        type: %i[chart table],
        admin_only: true,
        column_heading_explanation: :last_year_previous_year_definition_html
      },
      sept_nov_2021_2022_energy_comparison: {
        benchmark_class:  BenchmarkSeptNov2022Comparison,
        name:       'September to November 2021 versus 2022 energy use comparison',
        columns:  [
          tariff_changed_school_name,

          # kWh

          { data: ->{ sum_if_complete([s22e_pppk, s22g_pppk, s22s_pppk], [s22e_cppk, s22g_cppk, s22s_cppk]) }, name: :previous_year, units: :kwh },
          { data: ->{ sum_data([s22e_cppk, s22g_cppk, s22s_cppk]) },                                name: :last_year,  units: :kwh },
          {
            data: ->{ percent_change(
                                      sum_if_complete([s22e_pppk, s22g_pppk, s22s_pppk], [s22e_cppk, s22g_cppk, s22s_cppk]),
                                      sum_data([s22e_cppk, s22g_cppk, s22s_cppk]),
                                      true
                                    ) },
            name: :change_pct, units: :relative_percent_0dp
          },

          # CO2
          { data: ->{ sum_if_complete([s22e_pppc, s22g_pppc, s22s_pppc], [s22e_cppc, s22g_cppc, s22s_cppc]) }, name: :previous_year, units: :co2 },
          { data: ->{ sum_data([s22e_cppc, s22g_cppc, s22s_cppc]) },                                name: :last_year,  units: :co2 },
          {
            data: ->{ percent_change(
                                      sum_if_complete([s22e_pppc, s22g_pppc, s22s_pppc], [s22e_cppc, s22g_cppc, s22s_cppc]),
                                      sum_data([s22e_cppc, s22g_cppc, s22s_cppc]),
                                      true
                                    ) },
            name: :change_pct, units: :relative_percent_0dp
          },

          # £

          { data: ->{ sum_if_complete([s22e_ppp£, s22g_ppp£, s22s_ppp£], [s22e_cpp£, s22g_cpp£, s22s_cpp£]) }, name: :previous_year, units: :£ },
          { data: ->{ sum_data([s22e_cpp£, s22g_cpp£, s22s_cpp£]) },                                name: :last_year,  units: :£ },
          {
            data: ->{ percent_change(
                                      sum_if_complete([s22e_ppp£, s22g_ppp£, s22s_ppp£], [s22e_cpp£, s22g_cpp£, s22s_cpp£]),
                                      sum_data([s22e_cpp£, s22g_cpp£, s22s_cpp£]),
                                      true
                                    ) },
            name: :change_£, units: :relative_percent_0dp, chart_data: true
          },

          # Metering

          { data: ->{
              [
                s22e_ppp£.nil? ? nil : :electricity,
                s22g_ppp£.nil? ? nil : :gas,
                s22s_ppp£.nil? ? nil : :storage_heaters
              ].compact.join(', ')
            },
            name: :metering,
            units: String
          },
          TARIFF_CHANGED_COL
        ],
        column_groups: [
          { name: '',         span: 1 },
          { name: :kwh,      span: 3 },
          { name: :co2_kg, span: 3 },
          { name: :cost,     span: 3 },
          { name: '',         span: 1 }
        ],
        where:   ->{ !sum_data([s22e_ppp£, s22g_ppp£, s22s_ppp£], true).nil? },
        sort_by:  [9],
        type: %i[chart table],
        admin_only: true,
        column_heading_explanation: :last_year_previous_year_definition_html
      },
      change_in_energy_since_last_year: {
        benchmark_class:  BenchmarkChangeInEnergySinceLastYear,
        name:     'Change in energy use since last year',
        columns:  [
          { data: 'addp_name',              name: :name, units: :school_name, chart_data: true, content_class: 'AdviceBenchmark' },
          { data: ->{ sum_if_complete([enba_ken, enba_kgn, enba_khn, enba_ksn],
                                      [enba_ke0, enba_kg0, enba_kh0, enba_ks0]) }, name: :previous_year, units: :kwh },
          { data: ->{ sum_data([enba_ke0, enba_kg0, enba_kh0, enba_ks0]) }, name: :last_year, units: :kwh },
          { data: ->{ percent_change(
                        sum_if_complete(
                          [enba_ken, enba_kgn, enba_khn, enba_ksn],
                          [enba_ke0, enba_kg0, enba_kh0, enba_ks0]
                        ),
                        sum_data([enba_ke0, enba_kg0, enba_kh0, enba_ks0]),
                        true
                      )
                    },
                    name: :change_pct, units: :relative_percent_0dp
          },

          { data: ->{ sum_if_complete([enba_cen, enba_cgn, enba_chn, enba_csn],
                                      [enba_ce0, enba_cg0, enba_ch0, enba_cs0]) }, name: :previous_year, units: :co2 },
          { data: ->{ sum_data([enba_ce0, enba_cg0, enba_ch0, enba_cs0]) }, name: :last_year, units: :co2 },
          { data: ->{ percent_change(
                        sum_if_complete(
                          [enba_cen, enba_cgn, enba_chn, enba_csn],
                          [enba_ce0, enba_cg0, enba_ch0, enba_cs0]
                        ),
                        sum_data([enba_ce0, enba_cg0, enba_ch0, enba_cs0]),
                        true
                      )
                    },
                    name: :change_pct, units: :relative_percent_0dp
          },

          { data: ->{ sum_if_complete([enba_pen, enba_pgn, enba_phn, enba_psn],
                                      [enba_pe0, enba_pg0, enba_ph0, enba_ps0]) }, name: :previous_year, units: :£ },
          { data: ->{ sum_data([enba_pe0, enba_pg0, enba_ph0, enba_ps0]) }, name: :last_year, units: :£ },
          { data: ->{ percent_change(
                        sum_if_complete(
                          [enba_pen, enba_pgn, enba_phn, enba_psn],
                          [enba_pe0, enba_pg0, enba_ph0, enba_ps0]
                        ),
                        sum_data([enba_pe0, enba_pg0, enba_ph0, enba_ps0]),
                        true
                      )
                    },
                    name: :change_pct, units: :relative_percent_0dp
          },
          {
            data: ->{
              [
                enba_pe0.nil?     ? nil : 'E',
                enba_pg0.nil?     ? nil : 'G',
                enba_ph0.nil?     ? nil : 'SH',
                enba_solr == ''   ? nil : (enba_solr == 'synthetic' ? 's' : 'S')
              ].compact.join(' + ')
            },
            name: :fuel, units: String
          },
          {
            data: ->{
              (enba_peap == ManagementSummaryTable::NO_RECENT_DATA_MESSAGE ||
               enba_pgap == ManagementSummaryTable::NO_RECENT_DATA_MESSAGE) ? 'Y' : ''
             },
             name: :no_recent_data, units: String
          }
        ],
        column_groups: [
          { name: '',         span: 1 },
          { name: :kwh,      span: 3 },
          { name: :co2_kg, span: 3 },
          { name: :cost,     span: 3 },
          { name: :metering, span: 2 },
        ],
        where:   ->{ !sum_data([enba_ke0, enba_kg0, enba_kh0, enba_ks0], true).nil? },
        sort_by:  method(:sort_by_nil),
        type: %i[table],
        drilldown:  { type: :adult_dashboard, content_class: 'AdviceBenchmark' },
        admin_only: false,
        column_heading_explanation: :last_year_previous_year_definition_html
      },
      change_in_electricity_since_last_year: {
        benchmark_class:  BenchmarkChangeInElectricitySinceLastYear,
        name:     'Change in electricity consumption since last year',
        columns:  [
          { data: 'addp_name',  name: :name, units: :school_name, chart_data: true, content_class: 'AdviceBenchmark' },

          { data: ->{ enba_ken },                          name: :previous_year,  units: :kwh },
          { data: ->{ enba_ke0 },                          name: :last_year,      units: :kwh },
          { data: ->{ percent_change(enba_ken, enba_ke0)}, name: :change_pct,         units: :relative_percent_0dp },

          { data: ->{ enba_cen },                          name: :previous_year,  units: :co2 },
          { data: ->{ enba_ce0 },                          name: :last_year,      units: :co2 },
          { data: ->{ percent_change(enba_cen, enba_ce0)}, name: :change_pct,         units: :relative_percent_0dp },

          { data: ->{ enba_pen },                          name: :previous_year,  units: :£ },
          { data: ->{ enba_pe0 },                          name: :last_year,      units: :£ },
          { data: ->{ percent_change(enba_pen, enba_pe0)}, name: :change_pct,         units: :relative_percent_0dp },

          { data: ->{ enba_solr == 'synthetic' ? 'Y' : '' }, name: :estimated,  units: String },
        ],
        column_groups: [
          { name: '',                        span: 1 },
          { name: :kwh,                      span: 3 },
          { name: :co2_kg,                   span: 3 },
          { name: :gbp,                      span: 3 },
          { name: :solar_self_consumption,   span: 1 },
        ],
        where:   ->{ !enba_ken.nil? && enba_peap != ManagementSummaryTable::NO_RECENT_DATA_MESSAGE },
        sort_by:  [3],
        type: %i[table],
        drilldown:  { type: :adult_dashboard, content_class: 'AdviceBenchmark' },
        admin_only: false,
        column_heading_explanation: :last_year_previous_year_definition_html
      },
      change_in_gas_since_last_year: {
        benchmark_class:  BenchmarkChangeInGasSinceLastYear,
        name:     'Change in gas consumption since last year',
        columns:  [
          { data: 'addp_name',  name: :name, units: :school_name, chart_data: true, content_class: 'AdviceBenchmark' },

          { data: ->{ enba_kgn  },                         name: :previous_year,  units: :kwh },
          { data: ->{ gsba_kpya },                         name: :previous_year_temperature_adjusted,  units: :kwh },
          { data: ->{ enba_kg0 },                          name: :last_year,      units: :kwh },

          { data: ->{ enba_cgn },                          name: :previous_year,  units: :co2 },
          { data: ->{ enba_cg0 },                          name: :last_year,      units: :co2 },

          { data: ->{ enba_pgn },                          name: :previous_year,  units: :£ },
          { data: ->{ enba_pg0 },                          name: :last_year,      units: :£ },

          { data: ->{ percent_change(enba_kgn, enba_kg0)}, name: :unadjusted_kwh,    units: :relative_percent_0dp },
          { data: ->{ gsba_adpc },                         name: :temperature_adjusted_kwh, units: :relative_percent_0dp },
        ],
        column_groups: [
          { name: '',                 span: 1 },
          { name: :kwh,              span: 3 },
          { name: :co2_kg,         span: 2 },
          { name: :gbp,                span: 2 },
          { name: :percent_changed,  span: 2 },
        ],
        where:   ->{ !enba_kgn.nil? && enba_pgap != ManagementSummaryTable::NO_RECENT_DATA_MESSAGE },
        sort_by:  [3],
        type: %i[table],
        drilldown:  { type: :adult_dashboard, content_class: 'AdviceGasLongTerm' },
        admin_only: false,
        column_heading_explanation: :last_year_previous_year_definition_html
      },
      change_in_storage_heaters_since_last_year: {
        benchmark_class:  BenchmarkChangeInStorageHeatersSinceLastYear,
        name:     'Change in storage heater consumption since last year',
        columns:  [
          { data: 'addp_name',  name: :name, units: :school_name, chart_data: true, content_class: 'AdviceBenchmark' },

          { data: ->{ enba_khn  },                         name: :previous_year,  units: :kwh },
          { data: ->{ shan_kpya },                         name: :previous_year_temperature_adjusted,  units: :kwh },
          { data: ->{ enba_kh0 },                          name: :last_year,      units: :kwh },

          { data: ->{ enba_chn },                          name: :previous_year,  units: :co2 },
          { data: ->{ enba_ch0 },                          name: :last_year,      units: :co2 },

          { data: ->{ enba_phn },                          name: :previous_year,  units: :£ },
          { data: ->{ enba_ph0 },                          name: :last_year,      units: :£ },

          { data: ->{ percent_change(enba_khn, enba_kh0)}, name: :unadjusted_kwh,    units: :relative_percent_0dp },
          { data: ->{ shan_adpc },                         name: :temperature_adjusted_kwh, units: :relative_percent_0dp },
        ],
        column_groups: [
          { name: '',                 span: 1 },
          { name: :kwh,              span: 3 },
          { name: :co2_kg,         span: 2 },
          { name: :gbp,                span: 2 },
          { name: :percent_changed,  span: 2 }
        ],
        where:   ->{ !enba_khn.nil? && enba_phap != ManagementSummaryTable::NO_RECENT_DATA_MESSAGE },
        sort_by:  [3],
        type: %i[table],
        drilldown:  { type: :adult_dashboard, content_class: 'AdviceStorageHeaters' },
        admin_only: false,
        column_heading_explanation: :last_year_previous_year_definition_html
      },
      change_in_solar_pv_since_last_year: {
        benchmark_class:  BenchmarkChangeInSolarPVSinceLastYear,
        name:     'Change in solar PV production since last year',
        columns:  [
          { data: 'addp_name',  name: :name, units: :school_name, chart_data: true, content_class: 'AdviceBenchmark' },

          { data: ->{ enba_ksn },                          name: :previous_year,  units: :kwh },
          { data: ->{ enba_ks0 },                          name: :last_year,      units: :kwh },
          { data: ->{ percent_change(enba_ksn, enba_ks0)}, name: :change_pct,         units: :relative_percent_0dp },

          { data: ->{ enba_csn },                          name: :previous_year,  units: :co2 },
          { data: ->{ enba_cs0 },                          name: :last_year,      units: :co2 },
          { data: ->{ percent_change(enba_csn, enba_cs0)}, name: :change_pct,         units: :relative_percent_0dp },

          { data: ->{ enba_solr == 'synthetic' ? 'Y' : '' }, name: :estimated,  units: String },
        ],
        column_groups: [
          { name: '',                       span: 1 },
          { name: :kwh,                    span: 3 },
          { name: :co2_kg,               span: 3 },
          { name: :solar,                  span: 1 },
        ],
        where:   ->{ !enba_ksn.nil? && enba_psap != ManagementSummaryTable::NO_RECENT_DATA_MESSAGE },
        sort_by:  [3],
        type: %i[table],
        drilldown:  { type: :adult_dashboard, content_class: 'AdviceSolarPV' },
        admin_only: false,
        column_heading_explanation: :last_year_previous_year_definition_html
      },
      annual_electricity_costs_per_pupil: {
        benchmark_class:  BenchmarkContentElectricityPerPupil,
        name:     'Annual electricity use per pupil',
        columns:  [
          { data: 'addp_name',      name: :name, units: String, chart_data: true, content_class: 'AdviceElectricityAnnual' },
          { data: ->{ elba_£pup },  name: :last_year_electricity_£_pupil, units: :£_0dp, chart_data: true },
          { data: ->{ elba_£lyr },  name: :last_year_electricity_£, units: :£},
          { data: ->{ elba_€esav }, name: :saving_if_matched_exemplar_school, units: :£ },
          { data: ->{ elba_ratg },  name: :rating, units: Float, y2_axis: true },
        ],
        sort_by:  [1], # column 1 i.e. Annual kWh
        type: %i[table],
        admin_only: false,
        column_heading_explanation: :last_year_definition_html
      },
      electricity_targets: {
        benchmark_class:  BenchmarkElectricityTarget,
        name:     'Progress versus electricity target',
        columns:  [
          { data:   'addp_name',    name: :name, units: String, chart_data: true, content_class: 'AdviceElectricityAnnual' },
          { data: ->{ etga_tptd },  name: :percent_above_or_below_target_since_target_set, units: :relative_percent, chart_data: true },
          { data: ->{ etga_aptd },  name: :percent_above_or_below_last_year,  units: :relative_percent},
          { data: ->{ etga_cktd },  name: :kwh_consumption_since_target_set,  units: :kwh},
          { data: ->{ etga_tktd },  name: :target_kwh_consumption,            units: :kwh},
          { data: ->{ etga_uktd },  name: :last_year_kwh_consumption,         units: :kwh},
          { data: ->{ etga_trsd },  name: :start_date_for_target,             units: :date},
        ],
        sort_by:  [1], # column 1 i.e. annual refrigeration costs
        type: %i[chart table],
        admin_only: false,
        column_heading_explanation: :last_year_definition_html
      },
      annual_electricity_out_of_hours_use: {
        benchmark_class: BenchmarkContentElectricityOutOfHoursUsage,
        name:     'Electricity out of hours use',
        columns:  [
          tariff_changed_school_name('AdviceElectricityOutHours'),
          { data: ->{ eloo_sdop },  name: :school_day_open,              units: :percent, chart_data: true },
          { data: ->{ eloo_sdcp },  name: :school_day_closed,            units: :percent, chart_data: true },
          { data: ->{ eloo_holp },  name: :holiday,                      units: :percent, chart_data: true },
          { data: ->{ eloo_wkep },  name: :weekend,                      units: :percent, chart_data: true },
          { data: ->{ eloo_comp },  name: :community,                    units: :percent, chart_data: true },
          { data: ->{ eloo_com£ },  name: :community_usage_cost,         units: :£ },
          { data: ->{ eloo_aoo£ },  name: :last_year_out_of_hours_cost,  units: :£ },
          { data: ->{ eloo_esv€ },  name: :saving_if_improve_to_exemplar,units: :£ },
          { data: ->{ eloo_ratg },  name: :rating,                       units: Float, y2_axis: true },
          TARIFF_CHANGED_COL
        ],
        sort_by:  [1],
        type: %i[chart table],
        admin_only: false,
        column_heading_explanation: :last_year_definition_html
      },
      recent_change_in_baseload: {
        benchmark_class: BenchmarkContentChangeInBaseloadSinceLastYear,
        name:     'Last week\'s baseload versus average of last year (% difference)',
        columns:  [
          tariff_changed_school_name('AdviceBaseload'),
          { data: ->{ elbc_bspc }, name: :change_in_baseload_last_week_v_year_pct, units: :percent, chart_data: true},
          { data: ->{ elbc_blly }, name: :average_baseload_last_year_kw, units: :kw},
          { data: ->{ elbc_bllw }, name: :average_baseload_last_week_kw, units: :kw},
          { data: ->{ elbc_blch }, name: :change_in_baseload_last_week_v_year_kw, units: :kw},
          { data: ->{ elbc_anc€ }, name: :cost_of_change_in_baseload, units: :£current},
          { data: ->{ elbc_ratg }, name: :rating, units: Float, y2_axis: true },
          blended_baseload_rate_col(->{ elbc_€prk }),
          TARIFF_CHANGED_COL
        ],
        where:   ->{ !elbc_bspc.nil? },
        sort_by:  [1],
        type: %i[chart table],
        admin_only: false,
        column_heading_explanation: :last_year_definition_html
      },
      baseload_per_pupil: {
        benchmark_class: BenchmarkContentBaseloadPerPupil,
        name:     'Baseload per pupil',
        columns:  [
          tariff_changed_school_name('AdviceBaseload'),
          { data: ->{ elbb_blpp * 1000.0 }, name: :baseload_per_pupil_w, units: :w, chart_data: true},
          { data: ->{ elbb_lygb },  name: :last_year_cost_of_baseload, units: :£},
          { data: ->{ elbb_lykw },  name: :average_baseload_kw, units: :w},
          { data: ->{ elbb_abkp },  name: :baseload_percent, units: :percent},
          { data: ->{ [0.0, elbb_svex].max },  name: :saving_if_moved_to_exemplar, units: :£},
          { data: ->{ elbb_ratg },  name: :rating, units: Float, y2_axis: true },
          blended_baseload_rate_col(->{ elbb_€prk }),
          TARIFF_CHANGED_COL
        ],
        where:   ->{ !elbb_blpp.nil? },
        sort_by:  [1],
        type: %i[chart table],
        admin_only: false,
        column_heading_explanation: :last_year_definition_html
      },
      seasonal_baseload_variation: {
        benchmark_class: BenchmarkSeasonalBaseloadVariation,
        name:     'Seasonal baseload variation',
        columns:  [
          tariff_changed_school_name('AdviceBaseload'),
          { data: ->{ sblv_sblp }, name: :percent_increase_on_winter_baseload_over_summer, units: :relative_percent, chart_data: true},
          { data: ->{ sblv_smbl },  name: :summer_baseload_kw, units: :kw},
          { data: ->{ sblv_wtbl },  name: :winter_baseload_kw, units: :kw},
          { data: ->{ sblv_c€bp },  name: :saving_if_same_all_year_around, units: :£},
          { data: ->{ sblv_ratg },  name: :rating, units: Float, y2_axis: true },
          blended_baseload_rate_col(->{ sblv_€prk }),
          TARIFF_CHANGED_COL
        ],
        where:   ->{ !sblv_sblp.nil? },
        sort_by:  [1],
        type: %i[chart table],
        admin_only: false
      },
      weekday_baseload_variation: {
        benchmark_class: BenchmarkWeekdayBaseloadVariation,
        name:     'Weekday baseload variation',
        columns:  [
          tariff_changed_school_name('AdviceBaseload'),
          { data: ->{ iblv_sblp },  name: :variation_in_baseload_between_days_of_week, units: :relative_percent, chart_data: true},
          { data: ->{ iblv_mnbk },  name: :min_average_weekday_baseload_kw, units: :kw},
          { data: ->{ iblv_mxbk },  name: :max_average_weekday_baseload_kw, units: :kw},
          { data: ->{ iblv_mnbd },  name: :day_of_week_with_minimum_baseload, units: String},
          { data: ->{ iblv_mxbd },  name: :day_of_week_with_maximum_baseload, units: String},
          { data: ->{ iblv_c€bp },  name: :potential_saving, units: :£},
          { data: ->{ iblv_ratg },  name: :rating, units: Float, y2_axis: true },
          blended_baseload_rate_col(->{ iblv_€prk }),
          TARIFF_CHANGED_COL
        ],
        where:   ->{ !iblv_sblp.nil? },
        sort_by:  [1],
        type: %i[chart table],
        admin_only: false
      },
      electricity_peak_kw_per_pupil: {
        benchmark_class: BenchmarkContentPeakElectricityPerFloorArea,
        name:     'Peak school day electricity comparison kW/floor area',
        columns:  [
          tariff_changed_school_name('AdviceElectricityIntraday'),
          { data: ->{ epkb_kwfa * 1000.0 },  name: :w_floor_area,    units: :w, chart_data: true },
          { data: ->{ epkb_kwsc },  name: :average_peak_kw,  units: :kw },
          { data: ->{ epkb_kwex },  name: :exemplar_peak_kw, units: :kw },
          { data: ->{ epkb_tex£ },  name: :saving_if_match_exemplar_£, units: :£ },
          { data: ->{ epkb_ratg },  name: :rating, units: Float, y2_axis: true },
          TARIFF_CHANGED_COL
        ],
        where:   ->{ !epkb_kwfa.nil? },
        sort_by: [1],
        type: %i[table chart],
        admin_only: false
      },
      solar_pv_benefit_estimate: {
        benchmark_class: BenchmarkContentSolarPVBenefit,
        name:     'Benefit of estimated optimum size solar PV installation',
        columns:  [
          tariff_changed_school_name('AdviceSolarPV'),
          { data: ->{ sole_opvk },  name: :size_kwp,    units: :kwp},
          { data: ->{ sole_opvy },  name: :payback_years,  units: :years },
          { data: ->{ sole_opvp },  name: :reduction_in_mains_consumption_pct, units: :percent },
          { data: ->{ sole_opv€ },  name: :saving_optimal_panels, units: :£current },
          TARIFF_CHANGED_COL
        ],
        where:   ->{ !sole_opvk.nil? },
        sort_by: [1],
        type: %i[table],
        admin_only: false
      },
      annual_heating_costs_per_floor_area: {
        benchmark_class:  BenchmarkContentHeatingPerFloorArea,
        name:     'Annual heating cost per floor area',
        columns:  [
          tariff_changed_school_name('AdviceGasAnnual'),
          { data: ->{ sum_data([gsba_n£m2, shan_n£m2], true) },  name: :last_year_heating_costs_per_floor_area, units: :£, chart_data: true },
          { data: ->{ sum_data([gsba_£lyr, shan_£lyr], true) },  name: :last_year_cost_£, units: :£},
          { data: ->{ sum_data([gsba_s€ex, shan_s€ex], true) },  name: :saving_if_matched_exemplar_school, units: :£ },
          { data: ->{ sum_data([gsba_klyr, shan_klyr], true) },  name: :last_year_consumption_kwh, units: :kwh},
          { data: ->{ sum_data([gsba_co2y, shan_co2y], true) / 1000.0 },  name: :last_year_carbon_emissions_tonnes_co2, units: :co2},
          { data: ->{ or_nil([gsba_ratg, shan_ratg]) },  name: :rating, units: Float, y2_axis: true },
          TARIFF_CHANGED_COL
        ],
        where:   ->{ !gsba_co2y.nil? },
        sort_by:  [1],
        type: %i[chart table],
        admin_only: false,
        column_heading_explanation: :last_year_definition_html
      },
      annual_gas_out_of_hours_use: {
        benchmark_class: BenchmarkContentGasOutOfHoursUsage,
        name:     'Gas: out of hours use',
        columns:  [
          tariff_changed_school_name('AdviceGasOutHours'),
          { data: ->{ gsoo_sdop },  name: :school_day_open,              units: :percent, chart_data: true },
          { data: ->{ gsoo_sdcp },  name: :school_day_closed,            units: :percent, chart_data: true },
          { data: ->{ gsoo_holp },  name: :holiday,                      units: :percent, chart_data: true },
          { data: ->{ gsoo_wkep },  name: :weekend,                      units: :percent, chart_data: true },
          { data: ->{ gsoo_comp },  name: :community,                    units: :percent, chart_data: true },
          { data: ->{ gsoo_com£ },  name: :community_usage_cost,         units: :£ },
          { data: ->{ gsoo_aoo£ },  name: :last_year_out_of_hours_cost,     units: :£ },
          { data: ->{ gsoo_esv€ },  name: :saving_if_improve_to_exemplar,units: :£ },
          { data: ->{ gsoo_ratg },  name: :rating, units: Float, y2_axis: true },
          TARIFF_CHANGED_COL
        ],
        sort_by:  [1],
        type: %i[chart table],
        admin_only: false,
        column_heading_explanation: :last_year_definition_html
      },
      gas_targets: {
        benchmark_class:  BenchmarkGasTarget,
        name:     'Progress versus gas target',
        columns:  [
          { data:   'addp_name',    name: :name, units: String, chart_data: true, content_class: 'AdviceGasAnnual' },
          { data: ->{ gtga_tptd },  name: :percent_above_or_below_target_since_target_set, units: :relative_percent, chart_data: true },
          { data: ->{ gtga_aptd },  name: :percent_above_or_below_last_year,  units: :relative_percent},
          { data: ->{ gtga_cktd },  name: :kwh_consumption_since_target_set,  units: :kwh},
          { data: ->{ gtga_tktd },  name: :target_kwh_consumption,            units: :kwh},
          { data: ->{ gtga_uktd },  name: :last_year_kwh_consumption,         units: :kwh},
          { data: ->{ gtga_trsd },  name: :start_date_for_target,             units: :date},
        ],
        sort_by:  [1],
        type: %i[chart table],
        admin_only: false,
        column_heading_explanation: :last_year_definition_html
      },
      annual_storage_heater_out_of_hours_use: {
        benchmark_class: BenchmarkContentStorageHeaterOutOfHoursUsage,
        name:     'Storage heater out of hours use',
        columns:  [
          { data: 'addp_name',      name: :name,                  units: String,   chart_data: true, content_class: 'AdviceStorageHeaters' },
          { data: ->{ shoo_sdop },  name: :school_day_open,              units: :percent, chart_data: true },
          { data: ->{ shoo_sdcp },  name: :overnight_charging,           units: :percent, chart_data: true },
          { data: ->{ shoo_holp },  name: :holiday,                      units: :percent, chart_data: true },
          { data: ->{ shoo_wkep },  name: :weekend,                      units: :percent, chart_data: true },
          { data: ->{ sum_data([shoo_ahl£, shoo_awk£], true)  },  name: :last_year_weekend_and_holiday_costs, units: :£ },
          { data: ->{ shoo_ratg },  name: :rating, units: Float, y2_axis: true }
        ],
        sort_by:  [1],
        type: %i[chart table],
        admin_only: false,
        column_heading_explanation: :last_year_definition_html
      },
      heating_coming_on_too_early: {
        benchmark_class:  BenchmarkHeatingComingOnTooEarly,
        name:     'Heating start time (potentially coming on too early in morning)',
        columns:  [
          { data: 'addp_name',      name: :name,                                    units: String,   chart_data: true, content_class: 'AdviceGasBoilerMorningStart' },
          { data: ->{ hthe_htst },  name: :average_heating_start_time_last_week,    units: :timeofday, chart_data: true },
          { data: ->{ opts_avhm },  name: :average_heating_start_time_last_year,    units: :timeofday },
          { data: ->{ hthe_oss€ },  name: :last_year_saving_if_improve_to_exemplar, units: :£ },
          { data: ->{ hthe_ratg },  name: :rating, units: Float, y2_axis: true },
          TARIFF_CHANGED_COL
        ],
        sort_by:  [1],
        type: %i[chart table],
        admin_only: false,
        column_heading_explanation: :last_year_definition_html
      },
      thermostat_sensitivity: {
        benchmark_class:  BenchmarkContentThermostaticSensitivity,
        name:     'Annual saving through 1C reduction in thermostat temperature',
        columns:  [
          { data: 'addp_name',      name: :name,                  units: String,   chart_data: true },
          { data: ->{ htsa_td1c },  name: :last_year_saving_per_1c_reduction_in_thermostat, units: :£, chart_data: true },
          { data: ->{ htsa_ratg },  name: :rating, units: Float, y2_axis: true }
        ],
        sort_by:  [1],
        type: %i[chart table],
        admin_only: false
      },
      heating_in_warm_weather: {
        benchmark_class:  BenchmarkContentHeatingInWarmWeather,
        name:     'Gas or storage heater consumption for heating in warm weather',
        columns:  [
          { data: 'addp_name',      name: :name,           units: String, chart_data: true, content_class: 'AdviceGasBoilerSeasonalControl' },
          { data: ->{ or_nil([shsd_wpan, shsh_wpan]) },  name: :percentage_of_annual_heating_consumed_in_warm_weather, units: :percent, chart_data: true },
          { data: ->{ or_nil([shsd_wkwh, shsh_wkwh]) },  name: :saving_through_turning_heating_off_in_warm_weather_kwh, units: :kwh },
          { data: ->{ or_nil([shsd_wco2, shsh_wco2]) },  name: :saving_co2_kg, units: :co2 },
          { data: ->{ or_nil([shsd_w€__, shsh_w€__]) },  name: :saving_£, units: :£ },
          { data: ->{ or_nil([shsd_wdys, shsh_wdys]) },  name: :number_of_days_heating_on_in_warm_weather, units: :days },
          { data: ->{ or_nil([shsd_ratg, shsh_ratg]) },  name: :rating, units: Float, y2_axis: true }
        ],
        sort_by: [1],
        type: %i[chart table],
        admin_only: false
      },
      thermostatic_control: {
        benchmark_class:  BenchmarkContentThermostaticControl,
        name:     'Quality of thermostatic control',
        columns:  [
          { data: 'addp_name',      name: :name,     units: String, chart_data: true, content_class: 'AdviceGasThermostaticControl' },
          { data: ->{ or_nil([httc_r2, shtc_r2]) },    name: :thermostatic_r2, units: :r2,  chart_data: true },
          { data: ->{ sum_data([httc_sav€, shtc_sav€], true) },  name: :saving_through_improved_thermostatic_control, units: :£ },
          { data: ->{ httc_ratg },  name: :rating, units: Float, y2_axis: true }
        ],
        sort_by: [1],
        type: %i[chart table],
        admin_only: false
      },
      hot_water_efficiency: {
        benchmark_class:  BenchmarkContentHotWaterEfficiency,
        name:     'Hot Water Efficiency',
        columns:  [
          { data: 'addp_name',      name: :name, units: String, chart_data: true, content_class: 'AdviceGasHotWater' },
          { data: ->{ hotw_ppyr },  name: :cost_per_pupil, units: :£, chart_data: true},
          { data: ->{ hotw_eff  },  name: :efficiency_of_system, units: :percent},
          { data: ->{ hotw_gsav },  name: :saving_improving_timing, units: :£},
          { data: ->{ hotw_esav },  name: :saving_with_pou_electric_hot_water, units: :£},
          { data: ->{ hotw_ratg },  name: :rating, units: Float, y2_axis: true }
        ],
        sort_by:  [1],
        type: %i[chart table],
        admin_only: false
      },
      change_in_electricity_consumption_recent_school_weeks: {
        benchmark_class:  BenchmarkContentChangeInElectricityConsumptionSinceLastSchoolWeek,
        name:     'Change in electricity consumption since last school week',
        columns:  [
          { data: ->{ referenced(addp_name, eswc_pnch, eswc_difp, eswc_cppp) }, name: :name, units: String, chart_data: true, column_id: :school_name },
          { data: ->{ eswc_difp },  name: :change_pct, units: :relative_percent_0dp, chart_data: true, column_id: :percent_changed },
          { data: ->{ eswc_dif€ },  name: :change_£current,   units: :£_0dp },
          { data: ->{ eswc_difk },  name: :change_kwh, units: :kwh },
          { data: ->{ eswc_pnch },  aggregate_column: :dont_display_in_table_or_chart, units: TrueClass, column_id: :pupils_changed},
          { data: ->{ eswc_cpnp },  aggregate_column: :dont_display_in_table_or_chart, units: :pupils, column_id: :current_pupils},
          { data: ->{ eswc_ppnp },  aggregate_column: :dont_display_in_table_or_chart, units: :pupils, column_id: :previous_pupils},
          tariff_changed_between_periods(->{ eswc_cppp })
        ],
        where:   ->{ !eswc_difk.nil? },
        sort_by: [1],
        type: %i[table chart],
        admin_only: false
      },
      change_in_electricity_holiday_consumption_previous_holiday: {
        benchmark_class: BenchmarkContentChangeInElectricityBetweenLast2Holidays,
        name:     'Change in electricity consumption between the 2 most recent holidays',
        columns:  [
          { data: ->{ referenced(addp_name, ephc_pnch, ephc_difp, ephc_cppp) }, name: :name,     units: String, chart_data: true, column_id: :school_name },
          { data: ->{ ephc_difp },  name: :change_pct, units: :relative_percent_0dp, chart_data: true, column_id: :percent_changed },
          { data: ->{ ephc_dif€ },  name: :change_£current, units: :£_0dp },
          { data: ->{ ephc_difk },  name: :change_kwh, units: :kwh },
          { data: ->{ partial(ephc_cper, ephc_cptr) },  name: :most_recent_holiday, units: String },
          { data: ->{ ephc_pper },  name: :previous_holiday, units: String },
          { data: ->{ ephc_ratg },  name: :rating, units: Float, y2_axis: true },
          { data: ->{ ephc_pnch },  aggregate_column: :dont_display_in_table_or_chart, units: TrueClass, column_id: :pupils_changed},
          { data: ->{ ephc_cpnp },  aggregate_column: :dont_display_in_table_or_chart, units: :pupils, column_id: :current_pupils},
          { data: ->{ ephc_ppnp },  aggregate_column: :dont_display_in_table_or_chart, units: :pupils, column_id: :previous_pupils},
          tariff_changed_between_periods(->{ ephc_cppp })
        ],
        sort_by: [1],
        type: %i[table chart],
        admin_only: false
      },
      change_in_electricity_holiday_consumption_previous_years_holiday: {
        benchmark_class: BenchmarkContentChangeInElectricityBetween2HolidaysYearApart,
        name:     'Change in electricity consumption between this holiday and the same holiday the previous year',
        columns:  [
          { data: ->{ referenced(addp_name, epyc_pnch, epyc_difp, epyc_cppp) }, name: :name,     units: String, chart_data: true, column_id: :school_name },
          { data: ->{ epyc_difp },  name: :change_pct, units: :relative_percent_0dp, chart_data: true, column_id: :percent_changed },
          { data: ->{ epyc_dif€ },  name: :change_£current, units: :£_0dp },
          { data: ->{ epyc_difk },  name: :change_kwh, units: :kwh },
          { data: ->{ partial(epyc_cper, epyc_cptr) },  name: :most_recent_holiday, units: String },
          { data: ->{ epyc_pper },  name: :previous_holiday, units: String },
          { data: ->{ epyc_pnch },  aggregate_column: :dont_display_in_table_or_chart, units: TrueClass, column_id: :pupils_changed},
          { data: ->{ epyc_cpnp },  aggregate_column: :dont_display_in_table_or_chart, units: :pupils, column_id: :current_pupils},
          { data: ->{ epyc_ppnp },  aggregate_column: :dont_display_in_table_or_chart, units: :pupils, column_id: :previous_pupils},
          { data: ->{ epyc_ratg },  name: :rating, units: Float, y2_axis: true },
          tariff_changed_between_periods(->{ epyc_cppp })
        ],
        sort_by: [1],
        type: %i[table chart],
        admin_only: false
      },
      electricity_consumption_during_holiday: {
        benchmark_class: BenchmarkElectricityOnDuringHoliday,
        name:     'Electricity consumption during current holiday',
        columns:  [
          { data: 'addp_name',      name: :name,     units: String, chart_data: true },
          { data: ->{ edhl_£pro },  name: :projected_usage_by_end_of_holiday, units: :£, chart_data: true },
          { data: ->{ edhl_£sfr },  name: :holiday_usage_to_date, units: :£ },
          { data: ->{ edhl_hnam },  name: :holiday, units: String }
        ],
        sort_by: [1],
        type: %i[table chart],
        admin_only: false
      },
      change_in_gas_consumption_recent_school_weeks: {
        benchmark_class: BenchmarkContentChangeInGasConsumptionSinceLastSchoolWeek,
        name:     'Change in gas consumption since last school week',
        columns:  [
          { data: ->{ referenced(addp_name, gswc_pnch, gswc_difp, gswc_cppp) }, name: :name,     units: String, chart_data: true, column_id: :school_name },
          { data: ->{ gswc_difp },  name: :change_pct, units: :relative_percent_0dp, chart_data: true, column_id: :percent_changed },
          { data: ->{ gswc_dif€ },  name: :change_£current, units: :£_0dp },
          { data: ->{ gswc_difk },  name: :change_kwh, units: :kwh },
          { data: ->{ gswc_ratg },  name: :rating, units: Float, y2_axis: true },
          { data: ->{ gswc_fach },  aggregate_column: :dont_display_in_table_or_chart, units: TrueClass, column_id: :floor_area_changed},
          { data: ->{ gswc_cpfa },  aggregate_column: :dont_display_in_table_or_chart, units: :m2, column_id: :current_floor_area},
          { data: ->{ gswc_ppfa },  aggregate_column: :dont_display_in_table_or_chart, units: :m2, column_id: :previous_floor_area},
          tariff_changed_between_periods(->{ gswc_cppp })
        ],
        max_x_value:   100,
        sort_by: [1],
        type: %i[table chart],
        admin_only: false
      },
      change_in_gas_holiday_consumption_previous_holiday: {
        benchmark_class: BenchmarkContentChangeInGasBetweenLast2Holidays,
        name:     'Change in gas consumption between the 2 most recent holidays',
        columns:  [
          { data: ->{ referenced(addp_name, gphc_pnch, gphc_difp, gphc_cppp) }, name: :name, units: String, chart_data: true, column_id: :school_name },
          { data: ->{ gphc_difp },  name: :change_pct, units: :relative_percent_0dp, chart_data: true, column_id: :percent_changed },
          { data: ->{ gphc_dif€ },  name: :change_£current, units: :£_0dp },
          { data: ->{ gphc_difk },  name: :change_kwh, units: :kwh },
          { data: ->{ partial(gphc_cper, gphc_cptr) },  name: :most_recent_holiday, units: String },
          { data: ->{ gphc_pper },  name: :previous_holiday, units: String },
          { data: ->{ gphc_ratg },  name: :rating, units: Float, y2_axis: true },
          { data: ->{ gphc_fach },  aggregate_column: :dont_display_in_table_or_chart, units: TrueClass, column_id: :floor_area_changed},
          { data: ->{ gphc_cpfa },  aggregate_column: :dont_display_in_table_or_chart, units: :m2, column_id: :current_floor_area},
          { data: ->{ gphc_ppfa },  aggregate_column: :dont_display_in_table_or_chart, units: :m2, column_id: :previous_floor_area},
          tariff_changed_between_periods(->{ gphc_cppp })
        ],
        sort_by: [1],
        max_x_value:   100,
        # min_x_value:  -5,
        type: %i[table chart],
        admin_only: false
      },
      change_in_gas_holiday_consumption_previous_years_holiday: {
        benchmark_class: BenchmarkContentChangeInGasBetween2HolidaysYearApart,
        name:     'Change in gas consumption between this holiday and the same the previous year',
        columns:  [
          { data: ->{ referenced(addp_name, gpyc_pnch, gpyc_difp, gpyc_cppp) }, name: :name, units: String, chart_data: true, column_id: :school_name },
          { data: ->{ gpyc_difp },  name: :change_pct,   units: :relative_percent_0dp, chart_data: true, column_id: :percent_changed },
          { data: ->{ gpyc_dif€ },  name: :change_£current,   units: :£_0dp },
          { data: ->{ gpyc_difk },  name: :change_kwh, units: :kwh },
          { data: ->{ partial(gpyc_cper, gpyc_cptr) },  name: :most_recent_holiday, units: String },
          { data: ->{ gpyc_pper },  name: :previous_holiday, units: String },
          { data: ->{ gpyc_ratg },  name: :rating, units: Float, y2_axis: true },
          { data: ->{ gpyc_fach },  aggregate_column: :dont_display_in_table_or_chart, units: TrueClass,  column_id: :floor_area_changed},
          { data: ->{ gpyc_cpfa },  aggregate_column: :dont_display_in_table_or_chart, units: :m2,        column_id: :current_floor_area},
          { data: ->{ gpyc_ppfa },  aggregate_column: :dont_display_in_table_or_chart, units: :m2,        column_id: :previous_floor_area},
          tariff_changed_between_periods(->{ gpyc_cppp })
        ],
        max_x_value:   100,
        sort_by: [1],
        type: %i[table chart],
        admin_only: false
      },
      gas_consumption_during_holiday: {
        benchmark_class: BenchmarkGasHeatingHotWaterOnDuringHoliday,
        name:     'Gas consumption during current holiday',
        columns:  [
          { data: 'addp_name',      name: :name,     units: String, chart_data: true },
          { data: ->{ hdhl_£pro },  name: :projected_usage_by_end_of_holiday, units: :£, chart_data: true },
          { data: ->{ hdhl_£sfr },  name: :holiday_usage_to_date, units: :£ },
          { data: ->{ hdhl_hnam },  name: :holiday, units: String }
        ],
        sort_by: [1],
        type: %i[table chart],
        admin_only: false
      },
      storage_heater_consumption_during_holiday: {
        benchmark_class: BenchmarkStorageHeatersOnDuringHoliday,
        name:     'Storage heater consumption during current holiday',
        columns:  [
          { data: 'addp_name',      name: :name,     units: String, chart_data: true },
          { data: ->{ shoh_£pro },  name: :projected_usage_by_end_of_holiday, units: :£, chart_data: true },
          { data: ->{ shoh_£sfr },  name: :holiday_usage_to_date, units: :£ },
          { data: ->{ shoh_hnam },  name: :holiday, units: String }
        ],
        sort_by: [1],
        type: %i[table chart],
        admin_only: false
      },
      holiday_usage_last_year:  {
        benchmark_class: BenchmarkEnergyConsumptionInUpcomingHolidayLastYear,
        name:     'Energy Consumption in upcoming holiday last year',
        columns:  [
          { data: 'addp_name',      name: :name,                       units: String, chart_data: true },
          { data: ->{ ihol_glyr },  name: :gas_cost_ht,                units: :£, chart_data: true  },
          { data: ->{ ihol_elyr },  name: :electricity_cost_ht,        units: :£, chart_data: true },
          { data: ->{ ihol_g£ly },  name: :gas_cost_ct,                units: :£, chart_data: true  },
          { data: ->{ ihol_e£ly },  name: :electricity_cost_ct,        units: :£, chart_data: true },
          { data: ->{ ihol_gpfa },  name: :gas_kwh_per_floor_area,     units: :kwh },
          { data: ->{ ihol_epup },  name: :electricity_kwh_per_pupil,  units: :kwh },
          { data: ->{ ihol_pper },  name: :holiday,                    units: String },
        ],
        sort_by: [1],
        type: %i[table chart],
        admin_only: false
      },
      school_information: {
        benchmark_class:  nil,
        filter_out:     :dont_make_available_directly,
        name:     'School information - used for drilldown, not directly presented to user',
        columns:  [
          # the ordered and index of these 3 columns is important as hardcoded
          # indexes are used else where in the code [0] etc. to map between id and urn
          # def school_map()
          { data: 'addp_name',     name: :name, units: String,  chart_data: false },
          { data: 'addp_urn',      name: :urn,         units: Integer, chart_data: false },
          { data: ->{ school_id }, name: :school_id,   units: Integer, chart_data: false  }
        ],
        sort_by: [1],
        type: %i[table],
        admin_only: true
      },
      autumn_term_2021_2022_electricity_table: {
        benchmark_class:  BenchmarkAutumn2022ElectricityTable,
        filter_out:     :dont_make_available_directly,
        name:       'Autumn Term 2021 versus 2022 electricity use comparison',
        columns:  [
          tariff_changed_school_name,

          # kWh
          { data: ->{ a22e_pppk }, name: :previous_year, units: :kwh },
          { data: ->{ a22e_cppk }, name: :last_year,  units: :kwh },
          { data: ->{ percent_change(a22e_pppk, a22e_cppk, true) }, name: :change_pct, units: :relative_percent_0dp },

          # CO2
          { data: ->{ a22e_pppc }, name: :previous_year, units: :co2 },
          { data: ->{ a22e_cppc }, name: :last_year,  units: :co2 },
          { data: ->{ percent_change(a22e_pppc, a22e_cppc, true) }, name: :change_pct, units: :relative_percent_0dp },

          # £
          { data: ->{ a22e_ppp£ }, name: :previous_year, units: :£ },
          { data: ->{ a22e_cpp£ }, name: :last_year,  units: :£ },
          { data: ->{ percent_change(a22e_ppp£, a22e_cpp£, true) }, name: :change_pct, units: :relative_percent_0dp },

          TARIFF_CHANGED_COL
        ],
        column_groups: [
          { name: '',         span: 1 },
          { name: :kwh,      span: 3 },
          { name: :co2_kg, span: 3 },
          { name: :cost,     span: 3 }
        ],
        where:   ->{ !a22e_ppp£.nil? },
        sort_by:  [9],
        type: %i[table],
        admin_only: true
      },
      autumn_term_2021_2022_gas_table: {
        benchmark_class:  BenchmarkAutumn2022GasTable,
        filter_out:     :dont_make_available_directly,
        name:       'Autumn Term 2021 versus 2022 gas use comparison',
        columns:  [
          tariff_changed_school_name,

          # kWh
          { data: ->{ a22g_pppu }, name: :previous_year_temperature_unadjusted, units: :kwh },
          { data: ->{ a22g_pppk }, name: :previous_year_temperature_adjusted, units: :kwh },
          { data: ->{ a22g_cppk }, name: :last_year,  units: :kwh },
          { data: ->{ percent_change(a22g_pppk, a22g_cppk, true) }, name: :change_pct, units: :relative_percent_0dp },

          # CO2
          { data: ->{ a22g_pppc }, name: :previous_year, units: :co2 },
          { data: ->{ a22g_cppc }, name: :last_year,  units: :co2 },
          { data: ->{ percent_change(a22g_pppc, a22g_cppc, true) }, name: :change_pct, units: :relative_percent_0dp },

          # £
          { data: ->{ a22g_ppp£ }, name: :previous_year, units: :£ },
          { data: ->{ a22g_cpp£ }, name: :last_year,  units: :£ },
          { data: ->{ percent_change(a22g_ppp£, a22g_cpp£, true) }, name: :change_pct, units: :relative_percent_0dp },

          TARIFF_CHANGED_COL
        ],
        column_groups: [
          { name: '',         span: 1 },
          { name: :kwh,      span: 4 },
          { name: :co2_kg, span: 3 },
          { name: :cost,     span: 3 }
        ],
        where:   ->{ !a22g_ppp£.nil? },
        sort_by:  [9],
        type: %i[table],
        admin_only: true
      },
      autumn_term_2021_2022_storage_heater_table: {
        benchmark_class:  BenchmarkAutumn2022StorageHeaterTable,
        filter_out:     :dont_make_available_directly,
        name:       'Autumn Term 2021 versus 2022 storage heater use comparison',
        columns:  [
          tariff_changed_school_name,

          # kWh
          { data: ->{ a22s_pppu }, name: :previous_year_temperature_unadjusted, units: :kwh },
          { data: ->{ a22s_pppk }, name: :previous_year_temperature_adjusted, units: :kwh },
          { data: ->{ a22s_cppk }, name: :last_year,  units: :kwh },
          { data: ->{ percent_change(a22s_pppk, a22s_cppk, true) }, name: :change_pct, units: :relative_percent_0dp },

          # CO2
          { data: ->{ a22s_pppc }, name: :previous_year, units: :co2 },
          { data: ->{ a22s_cppc }, name: :last_year,  units: :co2 },
          { data: ->{ percent_change(a22s_pppc, a22s_cppc, true) }, name: :change_pct, units: :relative_percent_0dp },

          # £
          { data: ->{ a22s_ppp£ }, name: :previous_year, units: :£ },
          { data: ->{ a22s_cpp£ }, name: :last_year,  units: :£ },
          { data: ->{ percent_change(a22s_ppp£, a22s_cpp£, true) }, name: :change_pct, units: :relative_percent_0dp },

          TARIFF_CHANGED_COL
        ],
        column_groups: [
          { name: '',         span: 1 },
          { name: :kwh,      span: 4 },
          { name: :co2_kg, span: 3 },
          { name: :cost,     span: 3 }
        ],
        where:   ->{ !a22s_ppp£.nil? },
        sort_by:  [9],
        type: %i[table],
        admin_only: true
      },
      layer_up_powerdown_day_november_2022_electricity_table: {
        benchmark_class:  BenchmarkChangeAdhocComparisonElectricityTable,
        filter_out:     :dont_make_available_directly,
        name:       'Change in electricity for layer up power down day November 2022',
        columns:  [
          { data: 'addp_name', name: :name, units: :school_name },

          # kWh
          { data: ->{ lue1_pppk }, name: :previous_year, units: :kwh },
          { data: ->{ lue1_cppk }, name: :last_year,  units: :kwh },
          { data: ->{ percent_change(lue1_pppk, lue1_cppk, true) }, name: :change_pct, units: :relative_percent_0dp },

          # CO2
          { data: ->{ lue1_pppc }, name: :previous_year, units: :co2 },
          { data: ->{ lue1_cppc }, name: :last_year,  units: :co2 },
          { data: ->{ percent_change(lue1_pppc, lue1_cppc, true) }, name: :change_pct, units: :relative_percent_0dp },

          # £
          { data: ->{ lue1_ppp£ }, name: :previous_year, units: :£ },
          { data: ->{ lue1_cpp£ }, name: :last_year,  units: :£ },
          { data: ->{ percent_change(lue1_ppp£, lue1_cpp£, true) }, name: :change_pct, units: :relative_percent_0dp },

        ],
        column_groups: [
          { name: '',         span: 1 },
          { name: :kwh,      span: 4 },
          { name: :co2_kg, span: 3 },
          { name: :cost,     span: 3 }
        ],
        where:   ->{ !lue1_ppp£.nil? },
        sort_by:  [9],
        type: %i[table],
        admin_only: true
      },
      layer_up_powerdown_day_november_2022_gas_table: {
        benchmark_class:  BenchmarkChangeAdhocComparisonGasTable,
        filter_out:     :dont_make_available_directly,
        name:       'Change in gas for layer up power down day November 2022',
        columns:  [
          { data: 'addp_name', name: :name, units: :school_name },

          # kWh
          { data: ->{ lug1_pppu }, name: :previous_year_temperature_unadjusted, units: :kwh },
          { data: ->{ lug1_pppk }, name: :previous_year_temperature_adjusted, units: :kwh },
          { data: ->{ lug1_cppk }, name: :last_year,  units: :kwh },
          { data: ->{ percent_change(lug1_pppk, lug1_cppk, true) }, name: :change_pct, units: :relative_percent_0dp },

          # CO2
          { data: ->{ lug1_pppc }, name: :previous_year, units: :co2 },
          { data: ->{ lug1_cppc }, name: :last_year,  units: :co2 },
          { data: ->{ percent_change(lug1_pppc, lug1_cppc, true) }, name: :change_pct, units: :relative_percent_0dp },

          # £
          { data: ->{ lug1_ppp£ }, name: :previous_year, units: :£ },
          { data: ->{ lug1_cpp£ }, name: :last_year,  units: :£ },
          { data: ->{ percent_change(lug1_ppp£, lug1_cpp£, true) }, name: :change_pct, units: :relative_percent_0dp },

        ],
        column_groups: [
          { name: '',         span: 1 },
          { name: :kwh,      span: 3 },
          { name: :co2_kg, span: 3 },
          { name: :cost,     span: 3 }
        ],
        where:   ->{ !lug1_ppp£.nil? },
        sort_by:  [9],
        type: %i[table],
        admin_only: true
      },
      layer_up_powerdown_day_november_2022_storage_heater_table: {
        benchmark_class:  BenchmarkChangeAdhocComparisonStorageHeaterTable,
        filter_out:     :dont_make_available_directly,
        name:       'Change in gas for layer up power down day November 2022',
        columns:  [
          { data: 'addp_name', name: :name, units: :school_name },

          # kWh
          { data: ->{ lus1_pppu }, name: :previous_year_temperature_unadjusted, units: :kwh },
          { data: ->{ lus1_pppk }, name: :previous_year_temperature_adjusted, units: :kwh },
          { data: ->{ lus1_cppk }, name: :last_year,  units: :kwh },
          { data: ->{ percent_change(lus1_pppk, lus1_cppk, true) }, name: :change_pct, units: :relative_percent_0dp },

          # CO2
          { data: ->{ lus1_pppc }, name: :previous_year, units: :co2 },
          { data: ->{ lus1_cppc }, name: :last_year,  units: :co2 },
          { data: ->{ percent_change(lus1_pppc, lus1_cppc, true) }, name: :change_pct, units: :relative_percent_0dp },

          # £
          { data: ->{ lus1_ppp£ }, name: :previous_year, units: :£ },
          { data: ->{ lus1_cpp£ }, name: :last_year,  units: :£ },
          { data: ->{ percent_change(lus1_ppp£, lus1_cpp£, true) }, name: :change_pct, units: :relative_percent_0dp },

        ],
        column_groups: [
          { name: '',         span: 1 },
          { name: :kwh,      span: 3 },
          { name: :co2_kg, span: 3 },
          { name: :cost,     span: 3 }
        ],
        where:   ->{ !lus1_ppp£.nil? },
        sort_by:  [9],
        type: %i[table],
        admin_only: true
      },
      # second chart and table on page defined by change_in_energy_use_since_joined_energy_sparks above
      # not displayed on its own as a separate comparison
      change_in_energy_use_since_joined_energy_sparks_full_data: {
        benchmark_class:  BenchmarkContentChangeInEnergyUseSinceJoinedFullData,
        filter_out:       :dont_make_available_directly,
        name:     'breakdown in the change in energy use since the school joined Energy Sparks',
        columns:  [
          { data: 'addp_name',      name: :name, units: :school_name, chart_data: true },
          { data: ->{ addp_sact },  name: :energy_sparks_join_date, units: :date_mmm_yyyy },

          { data: ->{ enba_kea }, name: :year_before_joined,       units: :kwh },
          { data: ->{ enba_ke0 }, name: :last_year,                units: :kwh },
          { data: ->{ enba_keap}, name: :change_excluding_solar, units: :relative_percent_0dp, chart_data: true },

          { data: ->{ enba_kga }, name: :year_before_joined, units: :kwh },
          { data: ->{ enba_kg0 }, name: :last_year,          units: :kwh },
          { data: ->{ enba_kgap}, name: :change,             units: :relative_percent_0dp, chart_data: true },

          { data: ->{ enba_kha }, name: :year_before_joined, units: :kwh },
          { data: ->{ enba_kh0 }, name: :last_year,          units: :kwh },
          { data: ->{ enba_khap}, name: :change,             units: :relative_percent_0dp, chart_data: true },

          { data: ->{ enba_ksa }, name: :year_before_joined, units: :kwh },
          { data: ->{ enba_ks0 }, name: :last_year,          units: :kwh },
          { data: ->{ enba_ksap}, name: :change,             units: :relative_percent_0dp, chart_data: true },

          { data: ->{ enba_kxap },  name: :change,           units: :relative_percent_0dp, y2_axis: true }
        ],
        column_groups: [
          { name: '',                           span: 2 },
          { name: :electricity_consumption,     span: 3 },
          { name: :gas_consumption,             span: 3 },
          { name: :storage_heater_consumption,  span: 3 },
          { name: :solar_pv_production,         span: 3 },
          { name: :total_energy_consumption,    span: 1 }
        ],
        sort_by:  [13],
        type: %i[chart table],
        admin_only: true
      },
      optimum_start_analysis: {
        benchmark_class:  BenchmarkOptimumStartAnalysis,
        filter_out:     :dont_make_available_directly,
        name:     'Optimum start analysis',
        columns:  [
          { data: 'addp_name',      name: :name,      units: String, chart_data: true },
          { data: ->{ opts_avhm },  name: :average_heating_start_time_last_year,    units: :timeofday, chart_data: true },
          { data: ->{ opts_sdst },  name: :standard_deviation_of_start_time__hours_last_year,  units: :opt_start_standard_deviation },
          { data: ->{ opts_ratg },  name: :optimum_start_rating, units: Float },
          { data: ->{ opts_rmst },  name: :regression_model_optimum_start_time,  units: :morning_start_time },
          { data: ->{ opts_rmss },  name: :regression_model_optimum_start_sensitivity_to_outside_temperature,  units: :optimum_start_sensitivity },
          { data: ->{ opts_rmr2 },  name: :regression_model_optimum_start_r2,  units: :r2 },
          { data: ->{ hthe_htst },  name: :average_heating_start_time_last_week, units: :timeofday},
        ],
        sort_by: [1],
        type: %i[chart table],
        admin_only: true
      },
      sept_nov_2021_2022_electricity_table: {
        benchmark_class:  BenchmarkSeptNov2022ElectricityTable,
        filter_out:     :dont_make_available_directly,
        name:       'September to November 2021 versus 2022 electricity use comparison',
        columns:  [
          tariff_changed_school_name,

          # kWh
          { data: ->{ s22e_pppk }, name: :previous_year, units: :kwh },
          { data: ->{ s22e_cppk }, name: :last_year,  units: :kwh },
          { data: ->{ percent_change(s22e_pppk, s22e_cppk, true) }, name: :change_pct, units: :relative_percent_0dp },

          # CO2
          { data: ->{ s22e_pppc }, name: :previous_year, units: :co2 },
          { data: ->{ s22e_cppc }, name: :last_year,  units: :co2 },
          { data: ->{ percent_change(s22e_pppc, s22e_cppc, true) }, name: :change_pct, units: :relative_percent_0dp },

          # £
          { data: ->{ s22e_ppp£ }, name: :previous_year, units: :£ },
          { data: ->{ s22e_cpp£ }, name: :last_year,  units: :£ },
          { data: ->{ percent_change(s22e_ppp£, s22e_cpp£, true) }, name: :change_pct, units: :relative_percent_0dp },

          TARIFF_CHANGED_COL
        ],
        column_groups: [
          { name: '',         span: 1 },
          { name: :kwh,      span: 3 },
          { name: :co2_kg, span: 3 },
          { name: :cost,     span: 3 }
        ],
        where:   ->{ !s22e_ppp£.nil? },
        sort_by:  [9],
        type: %i[table],
        admin_only: true
      },
      sept_nov_2021_2022_gas_table: {
        benchmark_class:  BenchmarkSeptNov2022GasTable,
        filter_out:     :dont_make_available_directly,
        name:       'September to November 2021 versus 2022 gas use comparison',
        columns:  [
          tariff_changed_school_name,

          # kWh
          { data: ->{ s22g_pppu }, name: :previous_year_temperature_unadjusted, units: :kwh },
          { data: ->{ s22g_pppk }, name: :previous_year_temperature_adjusted, units: :kwh },
          { data: ->{ s22g_cppk }, name: :last_year,  units: :kwh },
          { data: ->{ percent_change(s22g_pppk, s22g_cppk, true) }, name: :change_pct, units: :relative_percent_0dp },

          # CO2
          { data: ->{ s22g_pppc }, name: :previous_year, units: :co2 },
          { data: ->{ s22g_cppc }, name: :last_year,  units: :co2 },
          { data: ->{ percent_change(s22g_pppc, s22g_cppc, true) }, name: :change_pct, units: :relative_percent_0dp },

          # £
          { data: ->{ s22g_ppp£ }, name: :previous_year, units: :£ },
          { data: ->{ s22g_cpp£ }, name: :last_year,  units: :£ },
          { data: ->{ percent_change(s22g_ppp£, s22g_cpp£, true) }, name: :change_pct, units: :relative_percent_0dp },

          TARIFF_CHANGED_COL
        ],
        column_groups: [
          { name: '',         span: 1 },
          { name: :kwh,      span: 4 },
          { name: :co2_kg, span: 3 },
          { name: :cost,     span: 3 }
        ],
        where:   ->{ !s22g_ppp£.nil? },
        sort_by:  [9],
        type: %i[table],
        admin_only: true
      },
      sept_nov_2021_2022_storage_heater_table: {
        benchmark_class:  BenchmarkSeptNov2022StorageHeaterTable,
        filter_out:     :dont_make_available_directly,
        name:       'September to November 2021 versus 2022 storage heater use comparison',
        columns:  [
          tariff_changed_school_name,

          # kWh
          { data: ->{ s22s_pppu }, name: :previous_year_temperature_unadjusted, units: :kwh },
          { data: ->{ s22s_pppk }, name: :previous_year_temperature_adjusted, units: :kwh },
          { data: ->{ s22s_cppk }, name: :last_year,  units: :kwh },
          { data: ->{ percent_change(s22s_pppk, s22s_cppk, true) }, name: :change_pct, units: :relative_percent_0dp },

          # CO2
          { data: ->{ s22s_pppc }, name: :previous_year, units: :co2 },
          { data: ->{ s22s_cppc }, name: :last_year,  units: :co2 },
          { data: ->{ percent_change(s22s_pppc, s22s_cppc, true) }, name: :change_pct, units: :relative_percent_0dp },

          # £
          { data: ->{ s22s_ppp£ }, name: :previous_year, units: :£ },
          { data: ->{ s22s_cpp£ }, name: :last_year,  units: :£ },
          { data: ->{ percent_change(s22s_ppp£, s22s_cpp£, true) }, name: :change_pct, units: :relative_percent_0dp },

          TARIFF_CHANGED_COL
        ],
        column_groups: [
          { name: '',         span: 1 },
          { name: :kwh,      span: 4 },
          { name: :co2_kg, span: 3 },
          { name: :cost,     span: 3 }
        ],
        where:   ->{ !s22s_ppp£.nil? },
        sort_by:  [9],
        type: %i[table],
        admin_only: true
      },
      easter_shutdown_2023_energy_comparison: {
        benchmark_class:  BenchmarkEaster2023ShutdownComparison,
        name:       'Easter shutdown 2023 energy use comparison',
        columns:  [
          tariff_changed_school_name,

          # kWh
          {
            data: ->{ sum_data([e23e_difk, e23g_difk, e23s_difk]) },
            name: :change_kwh,  units: :kwh
          },
          {
            data: ->{ percent_change(
                                      sum_if_complete([e23e_pppk, e23g_pppk, e23s_pppk], [e23e_cppk, e23g_cppk, e23s_cppk]),
                                      sum_data([e23e_cppk, e23g_cppk, e23s_cppk]),
                                      true
                                    ) },
            name: :change_pct, units: :relative_percent_0dp
          },

          # CO2
          {
            data: ->{ sum_data([e23e_difc, e23g_difc, e23s_difc]) },
            name: :change_co2,  units: :co2
          },
          {
            data: ->{ percent_change(
                                      sum_if_complete([e23e_pppc, e23g_pppc, e23s_pppc], [e23e_cppc, e23g_cppc, e23s_cppc]),
                                      sum_data([e23e_cppc, e23g_cppc, e23s_cppc]),
                                      true
                                    ) },
            name: :change_pct, units: :relative_percent_0dp
          },

          # £
          {
            data: ->{ sum_data([e23e_dif€, e23g_dif€, e23s_dif€]) },
            name: :change_£current,  units: :£
          },
          {
            data: ->{ percent_change(
                                      sum_if_complete([e23e_ppp€, e23g_ppp€, e23s_ppp€], [e23e_cpp€, e23g_cpp€, e23s_cpp€]),
                                      sum_data([e23e_cpp€, e23g_cpp€, e23s_cpp€]),
                                      true
                                    ) },
            name: :change_pct, units: :relative_percent_0dp, chart_data: true
          },

          # Metering

          { data: ->{
              [
                e23e_ppp£.nil? ? nil : :electricity,
                e23g_ppp£.nil? ? nil : :gas,
                e23s_ppp£.nil? ? nil : :storage_heaters
              ].compact.join(', ')
            },
            name: :metering,
            units: String
          },
          TARIFF_CHANGED_COL
        ],
        column_groups: [
          { name: '',         span: 1 },
          { name: :kwh,      span: 2 },
          { name: :co2_kg, span: 2 },
          { name: :cost,     span: 2 },
          { name: '',         span: 1 }
        ],
        where:   ->{ !sum_data([e23e_ppp£, e23g_ppp£, e23s_ppp£], true).nil? },
        sort_by:  [6],
        type: %i[table],
        admin_only: true
      },
      easter_shutdown_2023_electricity_table: {
        benchmark_class:  BenchmarkEasterShutdown2023ElectricityTable,
        filter_out:     :dont_make_available_directly,
        name:       'Easter shutdown 2023 electricity use comparison',
        columns:  [
          tariff_changed_school_name,

          { data: ->{ e23e_difk },  name: :change_kwh, units: :kwh },
          { data: ->{ e23e_difc },  name: :change_co2, units: :co2 },
          { data: ->{ e23e_dif€ },  name: :change_£current, units: :£_0dp },
          #percent
          { data: ->{ percent_change(e23e_pppk, e23e_cppk, true) }, name: :change_pct_combo, units: :relative_percent_0dp },
          # percent co2
          { data: ->{ percent_change(e23e_pppc, e23e_cppc, true) }, name: :change_pct_co2, units: :relative_percent_0dp },

          TARIFF_CHANGED_COL
        ],
        where:   ->{ !e23e_ppp£.nil? },
        sort_by:  [4],
        type: %i[table],
        admin_only: true
      },
      easter_shutdown_2023_gas_table: {
        benchmark_class:  BenchmarkEasterShutdown2023GasTable,
        filter_out:     :dont_make_available_directly,
        name:       'Easter shutdown 2023 gas use comparison',
        columns:  [
          tariff_changed_school_name,

          { data: ->{ e23g_difk },  name: :change_kwh, units: :kwh },
          { data: ->{ e23g_difc },  name: :change_co2, units: :co2 },
          { data: ->{ e23g_dif€ },  name: :change_£current, units: :£_0dp },
          # percent
          { data: ->{ percent_change(e23g_pppk, e23g_cppk, true) }, name: :change_pct, units: :relative_percent_0dp },

          TARIFF_CHANGED_COL
        ],
        where:   ->{ !e23g_ppp£.nil? },
        sort_by:  [4],
        type: %i[table],
        admin_only: true
      },
      easter_shutdown_2023_storage_heater_table: {
        benchmark_class:  BenchmarkEasterShutdown2023StorageHeaterTable,
        filter_out:     :dont_make_available_directly,
        name:       'Easter shutdown 2023 storage heater use comparison',
        columns:  [
          tariff_changed_school_name,

          { data: ->{ e23s_difk },  name: :change_kwh, units: :kwh },
          { data: ->{ e23s_difc },  name: :change_co2, units: :co2 },
          { data: ->{ e23s_dif€ },  name: :change_£current, units: :£_0dp },
          #percent
          { data: ->{ percent_change(e23s_pppk, e23s_cppk, true) }, name: :change_pct, units: :relative_percent_0dp },
          # percent co2
          { data: ->{ percent_change(e23s_pppc, e23s_cppc, true) }, name: :change_pct_co2, units: :relative_percent_0dp },

          TARIFF_CHANGED_COL
        ],
        where:   ->{ !e23s_ppp£.nil? },
        sort_by:  [4],
        type: %i[table],
        admin_only: true
      },
      annual_change_in_electricity_out_of_hours_use: {
        benchmark_class: BenchmarkContentAnnualChangeInElectricityOutOfHoursUsage,
        name:     'Annual change in electricity use out of hours',
        columns:  [
          tariff_changed_school_name('AdviceElectricityOutHours'),

          { data: ->{ elop_aook },  name: :previous_year_out_of_hours_kwh,  units: :kwh },
          { data: ->{ eloo_aook },  name: :last_year_out_of_hours_kwh,  units: :kwh },
          { data: ->{ percent_change(elop_aook, eloo_aook, true) }, name: :change_pct, units: :relative_percent_0dp },

          { data: ->{ elop_aooc },  name: :previous_year_out_of_hours_co2,  units: :co2 },
          { data: ->{ eloo_aooc },  name: :last_year_out_of_hours_co2,  units: :co2 },
          { data: ->{ percent_change(elop_aooc, eloo_aooc, true) }, name: :change_pct, units: :relative_percent_0dp },

          { data: ->{ elop_aoo€ },  name: :previous_year_out_of_hours_cost_ct,  units: :£ },
          { data: ->{ eloo_aoo€ },  name: :last_year_out_of_hours_cost_ct,  units: :£ },
          { data: ->{ percent_change(elop_aoo€, eloo_aoo€, true) }, name: :change_pct, units: :relative_percent_0dp },

          TARIFF_CHANGED_COL
        ],
        column_groups: [
          { name: '',       span: 1 },
          { name: :kwh,     span: 3 },
          { name: :co2_kg,     span: 3 },
          { name: :cost,    span: 3 },
        ],
        sort_by:  [1],
        type: %i[table],
        admin_only: false,
        column_heading_explanation: :last_year_definition_html
      },
      annual_change_in_gas_out_of_hours_use: {
        benchmark_class: BenchmarkContentAnnualChangeInGasOutOfHoursUsage,
        name:     'Annual change in gas use out of hours',
        columns:  [
          tariff_changed_school_name('AdviceGasOutHours'),

          { data: ->{ gsop_aook },  name: :previous_year_out_of_hours_kwh,  units: :kwh },
          { data: ->{ gsoo_aook },  name: :last_year_out_of_hours_kwh,  units: :kwh },
          { data: ->{ percent_change(gsop_aook, gsoo_aook, true) }, name: :change_pct, units: :relative_percent_0dp },

          { data: ->{ gsop_aooc },  name: :previous_year_out_of_hours_co2,  units: :co2 },
          { data: ->{ gsoo_aooc },  name: :last_year_out_of_hours_co2,  units: :co2 },
          { data: ->{ percent_change(gsop_aooc, gsoo_aooc, true) }, name: :change_pct, units: :relative_percent_0dp },

          { data: ->{ gsop_aoo€ },  name: :previous_year_out_of_hours_cost_ct,  units: :£ },
          { data: ->{ gsoo_aoo€ },  name: :last_year_out_of_hours_cost_ct,  units: :£ },
          { data: ->{ percent_change(gsop_aoo€, gsoo_aoo€, true) }, name: :change_pct, units: :relative_percent_0dp },

          TARIFF_CHANGED_COL
        ],
        column_groups: [
          { name: '',       span: 1 },
          { name: :kwh,     span: 3 },
          { name: :co2_kg,     span: 3 },
          { name: :cost,    span: 3 },
        ],
        sort_by:  [1],
        type: %i[table],
        admin_only: false,
        column_heading_explanation: :last_year_definition_html
      },
      annual_change_in_storage_heater_out_of_hours_use: {
        benchmark_class: BenchmarkContentAnnualChangeInStorageHeaterOutOfHoursUsage,
        name:     'Annual change in storage heater use out of hours',
        columns:  [
          tariff_changed_school_name('AdviceStorageHeaters'),

          { data: ->{ shop_aook },  name: :previous_year_out_of_hours_kwh,  units: :kwh },
          { data: ->{ shoo_aook },  name: :last_year_out_of_hours_kwh,  units: :kwh },
          { data: ->{ percent_change(shop_aook, shoo_aook, true) }, name: :change_pct, units: :relative_percent_0dp },

          { data: ->{ shop_aooc },  name: :previous_year_out_of_hours_co2,  units: :co2 },
          { data: ->{ shoo_aooc },  name: :last_year_out_of_hours_co2,  units: :co2 },
          { data: ->{ percent_change(shop_aooc, shoo_aooc, true) }, name: :change_pct, units: :relative_percent_0dp },

          { data: ->{ shop_aoo€ },  name: :previous_year_out_of_hours_cost_ct,  units: :£ },
          { data: ->{ shoo_aoo€ },  name: :last_year_out_of_hours_cost_ct,  units: :£ },
          { data: ->{ percent_change(shop_aoo€, shoo_aoo€, true) }, name: :change_pct, units: :relative_percent_0dp },

          TARIFF_CHANGED_COL
        ],
        column_groups: [
          { name: '',       span: 1 },
          { name: :kwh,     span: 3 },
          { name: :co2_kg,     span: 3 },
          { name: :cost,    span: 3 },
        ],
        where:   ->{ !shoo_aook.nil? },
        sort_by:  [1],
        type: %i[table],
        admin_only: false,
        column_heading_explanation: :last_year_definition_html
      },
      solar_generation_summary: {
        benchmark_class: BenchmarkContentSolarGenerationSummary,
        name:     'Solar generation summary',
        columns:  [
          { data: 'addp_name', name: :name,     units: String, chart_data: false },
          #generation
          { data: 'sgen_sagk', name: :solar_generation, units: :kwh},
          #self consume
          { data: 'sgen_sask', name: :solar_self_consume, units: :kwh},
          #export
          { data: 'sgen_saek', name: :solar_export, units: :kwh},
          #mains,
          { data: 'sgen_samk', name: :solar_mains_consume, units: :kwh},
          #mains, plus self consume
          { data: 'sgen_sack', name: :solar_mains_onsite, units: :kwh},
        ],
        where:   ->{ !sgen_sagk.nil? },
        sort_by:  [0],
        type: %i[table],
        admin_only: true
      },
      jan_august_2022_2023_energy_comparison: {
        benchmark_class:  BenchmarkJanAugust20222023Comparison,
        name:       'Jan-August 2022-2023 energy use comparison',
        columns:  [
          tariff_changed_school_name,

          { data: ->{ addp_sact },  name: :energy_sparks_join_date, units: :date_mmm_yyyy },

          # kWh
          {
            data: ->{ sum_data([py23e_difk, py23g_difk, py23s_difk]) },
            name: :change_kwh,  units: :kwh
          },
          {
            data: ->{ percent_change(
                                      sum_if_complete([py23e_pppk, py23g_pppk, py23s_pppk], [py23e_cppk, py23g_cppk, py23s_cppk]),
                                      sum_data([py23e_cppk, py23g_cppk,py23s_cppk]),
                                      true
                                    ) },
            name: :change_pct, units: :relative_percent_0dp
          },

          # CO2
          {
            data: ->{ sum_data([py23e_difc, py23g_difc, py23s_difc]) },
            name: :change_co2,  units: :co2
          },
          {
            data: ->{ percent_change(
                                      sum_if_complete([py23e_pppc, py23g_pppc, py23s_pppc], [py23e_cppc, py23g_cppc, py23s_cppc]),
                                      sum_data([py23e_cppc, py23g_cppc, py23s_cppc]),
                                      true
                                    ) },
            name: :change_pct, units: :relative_percent_0dp
          },

          # £
          {
            data: ->{ sum_data([py23e_dif€, py23g_dif€, py23s_dif€]) },
            name: :change_£current,  units: :£
          },
          {
            data: ->{ percent_change(
                                      sum_if_complete([py23e_ppp€, py23g_ppp€, py23s_ppp€], [py23e_cpp€, py23g_cpp€, py23s_cpp€]),
                                      sum_data([py23e_cpp€, py23g_cpp€, py23s_cpp€]),
                                      true
                                    ) },
            name: :change_pct, units: :relative_percent_0dp, chart_data: true
          },

          # Metering

          { data: ->{
              [
                py23e_ppp£.nil? ? nil : :electricity,
                py23g_ppp£.nil? ? nil : :gas,
                py23s_ppp£.nil? ? nil : :storage_heaters
              ].compact.join(', ')
            },
            name: :metering,
            units: String
          },
          { data: ->{ py23e_pnch ? 'Y' : 'N' }, name: :pupils, units: String },
          { data: ->{ py23g_fach ? 'Y' : 'N' }, name: :floor_area, units: String },

          TARIFF_CHANGED_COL
        ],
        column_groups: [
          { name: '',         span: 2 },
          { name: :kwh,      span: 2 },
          { name: :co2_kg, span: 2 },
          { name: :cost,     span: 2 },
          { name: '',         span: 3 }
        ],
        where:   ->{ !sum_data([py23e_ppp£, py23g_ppp£], true).nil? },
        sort_by:  [0],
        type: %i[table],
        admin_only: true
      },
      jan_august_2022_2023_electricity_table: {
        benchmark_class:  BenchmarkJanAugust20222023ComparisonElectricityTable,
        filter_out:     :dont_make_available_directly,
        name:       'Jan-August 2022-2023 electricity use comparison',
        columns:  [
          tariff_changed_school_name,

          { data: ->{ addp_sact },  name: :energy_sparks_join_date, units: :date_mmm_yyyy },

          #kwh
          { data: ->{ py23e_pppk },  name: :previous_year, units: :kwh },
          { data: ->{ py23e_cppk},   name: :last_year, units: :kwh},
          { data: ->{ py23e_difk },  name: :change_kwh, units: :kwh },
          { data: ->{ percent_change(py23e_pppk, py23e_cppk)}, name: :change_pct, units: :percent },

          #co2
          { data: ->{ py23e_pppc },  name: :previous_year, units: :co2 },
          { data: ->{ py23e_cppc },  name: :last_year, units: :co2},
          { data: ->{ py23e_difc },  name: :change_co2, units: :co2 },
          { data: ->{ percent_change(py23e_pppc, py23e_cppc)}, name: :change_pct, units: :percent },

          #£current
          { data: ->{ py23e_ppp€ },  name: :previous_year, units: :£current },
          { data: ->{ py23e_cpp€ },  name: :last_year, units: :£current},
          { data: ->{ py23e_dif€ },  name: :change_£, units: :£current },
          { data: ->{ percent_change(py23e_ppp€, py23e_cpp€)}, name: :change_pct, units: :percent },

          { data: ->{ py23e_pnch ? 'Y' : 'N' }, name: :pupils, units: String },
          { data: ->{ enba_solr == 'synthetic' ? 'Y' : '' }, name: :estimated,  units: String },

          TARIFF_CHANGED_COL
        ],
        column_groups: [
          { name: '',         span: 2 },
          { name: :kwh,      span: 4 },
          { name: :co2_kg, span: 4 },
          { name: :cost,     span: 4 },
          { name: '', span: 1 },
          { name: :solar_self_consumption,   span: 1 },
        ],
        where:   ->{ !py23e_ppp£.nil? },
        sort_by:  [0],
        type: %i[table],
        admin_only: true
      },
      jan_august_2022_2023_gas_table: {
        benchmark_class:  BenchmarkJanAugust20222023ComparisonGasTable,
        filter_out:     :dont_make_available_directly,
        name:       'Jan-August 2022-2023 gas use comparison',
        columns:  [
          tariff_changed_school_name,

          { data: ->{ addp_sact },  name: :energy_sparks_join_date, units: :date_mmm_yyyy },

          #kwh
          { data: ->{ py23g_pppk },  name: :previous_year_temperature_unadjusted, units: :kwh },
          { data: ->{ py23g_cppk},   name: :last_year, units: :kwh},
          { data: ->{ py23g_difk },  name: :change_kwh, units: :kwh },
          { data: ->{ percent_change(py23g_pppk, py23g_cppk)}, name: :change_pct, units: :percent },

          #co2
          { data: ->{ py23g_pppc },  name: :previous_year, units: :co2 },
          { data: ->{ py23g_cppc },  name: :last_year, units: :co2},
          { data: ->{ py23g_difc },  name: :change_co2, units: :co2 },
          { data: ->{ percent_change(py23g_pppc, py23g_cppc)}, name: :change_pct, units: :percent },

          #£current
          { data: ->{ py23g_ppp€ },  name: :previous_year, units: :£current },
          { data: ->{ py23g_cpp€ },  name: :last_year, units: :£current},
          { data: ->{ py23g_dif€ },  name: :change_£, units: :£current },
          { data: ->{ percent_change(py23g_ppp€, py23g_cpp€)}, name: :change_pct, units: :percent },

          { data: ->{ py23g_fach ? 'Y' : 'N' }, name: :floor_area, units: String },

          TARIFF_CHANGED_COL
        ],
        column_groups: [
          { name: '',         span: 2 },
          { name: :kwh,      span: 4 },
          { name: :co2_kg, span: 4 },
          { name: :cost,     span: 4 },
          { name: :kwh, span: 3},
          { name: '', span: 1}
        ],
        where:   ->{ !py23g_ppp£.nil? },
        sort_by:  [0],
        type: %i[table],
        admin_only: true
      },
      jan_august_2022_2023_storage_heater_table: {
        benchmark_class:  BenchmarkJanAugust20222023ComparisonStorageHeaterTable,
        filter_out:     :dont_make_available_directly,
        name:       'Jan-August 2022-2023 storage heater use comparison',
        columns:  [
          tariff_changed_school_name,

          { data: ->{ addp_sact },  name: :energy_sparks_join_date, units: :date_mmm_yyyy },

          #kwh
          { data: ->{ py23s_pppk },  name: :previous_year_temperature_unadjusted, units: :kwh },
          { data: ->{ py23s_cppk},   name: :last_year, units: :kwh},
          { data: ->{ py23s_difk },  name: :change_kwh, units: :kwh },
          { data: ->{ percent_change(py23s_pppk, py23s_cppk)}, name: :change_pct, units: :percent },

          #co2
          { data: ->{ py23s_pppc },  name: :previous_year, units: :co2 },
          { data: ->{ py23s_cppc },  name: :last_year, units: :co2},
          { data: ->{ py23s_difc },  name: :change_co2, units: :co2 },
          { data: ->{ percent_change(py23s_pppc, py23s_cppc)}, name: :change_pct, units: :percent },

          #£current
          { data: ->{ py23s_ppp€ },  name: :previous_year, units: :£current },
          { data: ->{ py23s_cpp€ },  name: :last_year, units: :£current},
          { data: ->{ py23s_dif€ },  name: :change_£, units: :£current },
          { data: ->{ percent_change(py23s_ppp€, py23s_cpp€)}, name: :change_pct, units: :percent },

          { data: ->{ py23s_fach ? 'Y' : 'N' }, name: :floor_area, units: String },

          TARIFF_CHANGED_COL
        ],
        column_groups: [
          { name: '',         span: 2 },
          { name: :kwh,      span: 4 },
          { name: :co2_kg, span: 4 },
          { name: :cost,     span: 4 },
          { name: :kwh, span: 3},
          { name: '', span: 1}
        ],
        where:   ->{ !py23s_ppp£.nil? },
        sort_by:  [0],
        type: %i[table],
        admin_only: true
      },
      layer_up_powerdown_day_november_2023: {
        benchmark_class:  BenchmarkLayerUpPowerDownDay2023Comparison,
        name:       'Change in energy for layer up power down day 24 November 2023 (compared with 17 November 2023)',
        columns:  [
          { data: 'addp_name', name: :name, units: :school_name, chart_data: true},

          # kWh

          { data: ->{ sum_if_complete([lu23e1_pppk, lu23g1_pppk, lu23s1_pppk], [lu23e1_cppk, lu23g1_cppk, lu23s1_cppk]) }, name: :previous_day, units: :kwh },
          { data: ->{ sum_data([lu23e1_cppk, lu23g1_cppk, lu23s1_cppk]) },                                name: :layer_down_day,  units: :kwh },
          {
            data: ->{ percent_change(
                                      sum_if_complete([lu23e1_pppk, lu23g1_pppk, lu23s1_pppk], [lu23e1_cppk, lu23g1_cppk, lu23s1_cppk]),
                                      sum_data([lu23e1_cppk, lu23g1_cppk, lu23s1_cppk]),
                                      true
                                    ) },
            name: :change_pct, units: :relative_percent_0dp
          },

          # CO2
          { data: ->{ sum_if_complete([lu23e1_pppc, lu23g1_pppc, lu23s1_pppc], [lu23e1_cppc, lu23g1_cppc, lu23s1_cppc]) }, name: :previous_day, units: :co2 },
          { data: ->{ sum_data([lu23e1_cppc, lu23g1_cppc, lu23s1_cppc]) },                                name: :layer_down_day,  units: :co2 },
          {
            data: ->{ percent_change(
                                      sum_if_complete([lu23e1_pppc, lu23g1_pppc, lu23s1_pppc], [lu23e1_cppc, lu23g1_cppc, lu23s1_cppc]),
                                      sum_data([lu23e1_cppc, lu23g1_cppc, lu23s1_cppc]),
                                      true
                                    ) },
            name: :change_pct, units: :relative_percent_0dp
          },

          # £

          { data: ->{ sum_if_complete([lu23e1_ppp£, lu23g1_ppp£, lu23s1_ppp£], [lu23e1_cpp£, lu23g1_cpp£, lu23s1_cpp£]) }, name: :previous_day, units: :£ },
          { data: ->{ sum_data([lu23e1_cpp£, lu23g1_cpp£, lu23s1_cpp£]) },                                name: :layer_down_day,  units: :£ },
          {
            data: ->{ percent_change(
                                      sum_if_complete([lu23e1_ppp£, lu23g1_ppp£, lu23s1_ppp£], [lu23e1_cpp£, lu23g1_cpp£, lu23s1_cpp£]),
                                      sum_data([lu23e1_cpp£, lu23g1_cpp£, lu23s1_cpp£]),
                                      true
                                    ) },
            name: :change_£, units: :relative_percent_0dp, chart_data: true
          },

          # Metering

          { data: ->{
              [
                lu23e1_ppp£.nil? ? nil : :electricity,
                lu23g1_ppp£.nil? ? nil : :gas,
                lu23s1_ppp£.nil? ? nil : :storage_heaters
              ].compact.join(', ')
            },
            name: :metering,
            units: String
          },
        ],
        column_groups: [
          { name: '',         span: 1 },
          { name: :kwh,       span: 3 },
          { name: :co2_kg,    span: 3 },
          { name: :cost,      span: 3 },
          { name: '',         span: 1 }
        ],
        where:   ->{ !sum_data([lu23e1_ppp£, lu23g1_ppp£, lu23s1_ppp£], true).nil? },
        sort_by:  [9],
        type: %i[chart table],
        admin_only: true
      },
      layer_up_powerdown_day_november_2023_electricity_table: {
        benchmark_class:  BenchmarkLayerUpPowerDownDay2023ComparisonElectricityTable,
        filter_out:     :dont_make_available_directly,
        name:       'Change in electricity for layer up power down day November 2023',
        columns:  [
          { data: 'addp_name', name: :name, units: :school_name },

          # kWh
          { data: ->{ lu23e1_pppk }, name: :previous_day, units: :kwh },
          { data: ->{ lu23e1_cppk }, name: :layer_down_day,  units: :kwh },
          { data: ->{ percent_change(lu23e1_pppk, lu23e1_cppk, true) }, name: :change_pct, units: :relative_percent_0dp },

          # CO2
          { data: ->{ lu23e1_pppc }, name: :previous_day, units: :co2 },
          { data: ->{ lu23e1_cppc }, name: :layer_down_day,  units: :co2 },
          { data: ->{ percent_change(lu23e1_pppc, lu23e1_cppc, true) }, name: :change_pct, units: :relative_percent_0dp },

          # £
          { data: ->{ lu23e1_ppp£ }, name: :previous_day, units: :£ },
          { data: ->{ lu23e1_cpp£ }, name: :layer_down_day,  units: :£ },
          { data: ->{ percent_change(lu23e1_ppp£, lu23e1_cpp£, true) }, name: :change_pct, units: :relative_percent_0dp },

        ],
        column_groups: [
          { name: '',         span: 1 },
          { name: :kwh,      span: 4 },
          { name: :co2_kg, span: 3 },
          { name: :cost,     span: 3 }
        ],
        where:   ->{ !lu23e1_ppp£.nil? },
        sort_by:  [9],
        type: %i[table],
        admin_only: true
      },
      layer_up_powerdown_day_november_2023_gas_table: {
        benchmark_class:  BenchmarkLayerUpPowerDownDay2023ComparisonGasTable,
        filter_out:     :dont_make_available_directly,
        name:       'Change in gas for layer up power down day November 2023',
        columns:  [
          { data: 'addp_name', name: :name, units: :school_name },

          # kWh
          { data: ->{ lu23g1_pppu }, name: :previous_day_temperature_unadjusted, units: :kwh },
          { data: ->{ lu23g1_pppk }, name: :previous_day, units: :kwh },
          { data: ->{ lu23g1_cppk }, name: :layer_down_day,  units: :kwh },
          { data: ->{ percent_change(lu23g1_pppk, lu23g1_cppk, true) }, name: :change_pct, units: :relative_percent_0dp },

          # CO2
          { data: ->{ lu23g1_pppc }, name: :previous_day, units: :co2 },
          { data: ->{ lu23g1_cppc }, name: :layer_down_day,  units: :co2 },
          { data: ->{ percent_change(lu23g1_pppc, lu23g1_cppc, true) }, name: :change_pct, units: :relative_percent_0dp },

          # £
          { data: ->{ lu23g1_ppp£ }, name: :previous_day, units: :£ },
          { data: ->{ lu23g1_cpp£ }, name: :layer_down_day,  units: :£ },
          { data: ->{ percent_change(lu23g1_ppp£, lu23g1_cpp£, true) }, name: :change_pct, units: :relative_percent_0dp },

        ],
        column_groups: [
          { name: '',         span: 1 },
          { name: :kwh,      span: 3 },
          { name: :co2_kg, span: 3 },
          { name: :cost,     span: 3 }
        ],
        where:   ->{ !lu23g1_ppp£.nil? },
        sort_by:  [9],
        type: %i[table],
        admin_only: true
      },
      layer_up_powerdown_day_november_2023_storage_heater_table: {
        benchmark_class:  BenchmarkLayerUpPowerDownDay2023ComparisonStorageHeaterTable,
        filter_out:     :dont_make_available_directly,
        name:       'Change in gas for layer up power down day November 2023',
        columns:  [
          { data: 'addp_name', name: :name, units: :school_name },

          # kWh
          { data: ->{ lu23s1_pppu }, name: :previous_day_temperature_unadjusted, units: :kwh },
          { data: ->{ lu23s1_pppk }, name: :previous_day, units: :kwh },
          { data: ->{ lu23s1_cppk }, name: :layer_down_day,  units: :kwh },
          { data: ->{ percent_change(lu23s1_pppk, lu23s1_cppk, true) }, name: :change_pct, units: :relative_percent_0dp },

          # CO2
          { data: ->{ lu23s1_pppc }, name: :previous_day, units: :co2 },
          { data: ->{ lu23s1_cppc }, name: :layer_down_day,  units: :co2 },
          { data: ->{ percent_change(lu23s1_pppc, lu23s1_cppc, true) }, name: :change_pct, units: :relative_percent_0dp },

          # £
          { data: ->{ lu23s1_ppp£ }, name: :previous_day, units: :£ },
          { data: ->{ lu23s1_cpp£ }, name: :layer_down_day,  units: :£ },
          { data: ->{ percent_change(lu23s1_ppp£, lu23s1_cpp£, true) }, name: :change_pct, units: :relative_percent_0dp },

        ],
        column_groups: [
          { name: '',         span: 1 },
          { name: :kwh,      span: 3 },
          { name: :co2_kg, span: 3 },
          { name: :cost,     span: 3 }
        ],
        where:   ->{ !lu23s1_ppp£.nil? },
        sort_by:  [9],
        type: %i[table],
        admin_only: true
      },
      heat_saver_march_2024: {
        admin_only: true
      } # only implemented in the application
    }.freeze
  end
end
