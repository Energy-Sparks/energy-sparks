require_relative './benchmark_no_text_mixin.rb'
require_relative './benchmark_content_base.rb'

module Benchmarking
  class BenchmarkContentEnergyPerPupil < BenchmarkContentBase
    include BenchmarkingNoTextMixin

    private def introduction_text
      text =  I18n.t('analytics.benchmarking.content.annual_energy_costs_per_pupil.introduction_text_html')
      text += I18n.t('analytics.benchmarking.caveat_text.es_per_pupil_v_per_floor_area_html')
      text += I18n.t('analytics.benchmarking.caveat_text.es_doesnt_have_all_meter_data_html')
      ERB.new(text).result(binding)
    end
  end
#=======================================================================================
  class BenchmarkOptimumStartAnalysis  < BenchmarkContentBase
    include BenchmarkingNoTextMixin

    private def introduction_text
      I18n.t('analytics.benchmarking.content.optimum_start_analysis.introduction_text_html')
    end

    protected def table_introduction_text
      I18n.t('analytics.benchmarking.content.optimum_start_analysis.table_introduction_text_html')
    end

    protected def caveat_text
      I18n.t('analytics.benchmarking.content.optimum_start_analysis.caveat_text_html')
    end
  end


  #=======================================================================================
  class BenchmarkContentChangeInEnergyUseSinceJoinedFullData < BenchmarkContentBase
    include BenchmarkingNoTextMixin

    private def introduction_text
      text =  I18n.t('analytics.benchmarking.content.change_in_energy_use_since_joined_full_data.introduction_text_html')
      ERB.new(text).result(binding)
    end
  end
  #=======================================================================================
  class BenchmarkContentTotalAnnualEnergy < BenchmarkContentBase
    include BenchmarkingNoTextMixin
    private def introduction_text
      text = I18n.t('analytics.benchmarking.content.annual_energy_costs.introduction_text_html')
      text += I18n.t('analytics.benchmarking.caveat_text.es_doesnt_have_all_meter_data_html')
      ERB.new(text).result(binding)
    end
    protected def table_interpretation_text
      I18n.t('analytics.benchmarking.caveat_text.es_data_not_in_sync_html')
    end
  end
  #=======================================================================================
  class BenchmarkContentElectricityPerPupil < BenchmarkContentBase
    include BenchmarkingNoTextMixin
    private def introduction_text
      I18n.t('analytics.benchmarking.content.annual_electricity_costs_per_pupil.introduction_text_html')
    end
  end
  #=======================================================================================
  class BenchmarkContentElectricityOutOfHoursUsage < BenchmarkContentBase
    include BenchmarkingNoTextMixin

    private def introduction_text
      text = I18n.t('analytics.benchmarking.content.annual_electricity_out_of_hours_use.introduction_text_html')
      text += I18n.t('analytics.benchmarking.caveat_text.es_exclude_storage_heaters_and_solar_pv_html')
      ERB.new(text).result(binding)
    end
  end
  #=======================================================================================
  class BenchmarkContentAnnualChangeInElectricityOutOfHoursUsage < BenchmarkContentBase
    include BenchmarkingNoTextMixin

    private def introduction_text
      text = I18n.t('analytics.benchmarking.content.annual_change_in_electricity_out_of_hours_use.introduction_text_html')
      text += I18n.t('analytics.benchmarking.content.annual_change_in_out_of_hours_use.table_html')
      ERB.new(text).result(binding)
    end
  end
  #=======================================================================================
  class BenchmarkContentAnnualChangeInGasOutOfHoursUsage < BenchmarkContentBase
    include BenchmarkingNoTextMixin

    private def introduction_text
      text = I18n.t('analytics.benchmarking.content.annual_change_in_gas_out_of_hours_use.introduction_text_html')
      text += I18n.t('analytics.benchmarking.content.annual_change_in_out_of_hours_use.table_html')
      ERB.new(text).result(binding)
    end
  end
  #=======================================================================================
  class BenchmarkContentAnnualChangeInStorageHeaterOutOfHoursUsage < BenchmarkContentBase
    include BenchmarkingNoTextMixin

    private def introduction_text
      text = I18n.t('analytics.benchmarking.content.annual_change_in_storage_heater_out_of_hours_use.introduction_text_html')
      text += I18n.t('analytics.benchmarking.content.annual_change_in_out_of_hours_use.table_html')
      ERB.new(text).result(binding)
    end
  end
  #=======================================================================================
  class BenchmarkContentSolarGenerationSummary < BenchmarkContentBase
    include BenchmarkingNoTextMixin

    private def introduction_text
      text = I18n.t('analytics.benchmarking.content.solar_generation_summary.introduction_text_html')
      ERB.new(text).result(binding)
    end
  end

  #=======================================================================================
  class BenchmarkBaseloadBase < BenchmarkContentBase
    def content(school_ids: nil, filter: nil, user_type: nil)
      @baseload_impact_html = baseload_1_kw_change_range_£_html(school_ids, filter, user_type)
      super(school_ids: school_ids, filter: filter)
    end

    def baseload_1_kw_change_range_£_html(school_ids, filter, user_type)
      cost_of_1_kw_baseload_range_£ = calculate_cost_of_1_kw_baseload_range_£(school_ids, filter, user_type)

      cost_of_1_kw_baseload_range_£_html = cost_of_1_kw_baseload_range_£.map do |costs_£|
        FormatEnergyUnit.format(:£, costs_£, :html)
      end

      if cost_of_1_kw_baseload_range_£_html.empty?
        '<p></p>'
      elsif cost_of_1_kw_baseload_range_£_html.length == 1
        I18n.t(
          'analytics.benchmarking.content.benchmark_baseload_base.baseload_1_kw_change_range_£_html.one_value_html',
          value_gbp: cost_of_1_kw_baseload_range_£_html.first
        )
      else
        I18n.t(
          'analytics.benchmarking.content.benchmark_baseload_base.baseload_1_kw_change_range_£_html.two_value_html',
          value_first_gbp: cost_of_1_kw_baseload_range_£_html.first,
          value_last_gbp: cost_of_1_kw_baseload_range_£_html.last
        )
      end
    end

    def calculate_cost_of_1_kw_baseload_range_£(school_ids, filter, user_type)
      rates = calculate_blended_rate_range(school_ids, filter, user_type)

      hours_per_year = 24.0 * 365
      rates.map { |rate| rate * hours_per_year }
    end

    def calculate_blended_rate_range(school_ids, filter, user_type)
      blended_current_rate_header = I18n.t("analytics.benchmarking.configuration.column_headings.blended_current_rate")
      col_index = column_headings(school_ids, filter, user_type).index(blended_current_rate_header)
      data = raw_data(school_ids, filter, user_type)
      return [] if data.nil? || data.empty?

      blended_rate_per_kwhs = data.map { |row| row[col_index] }.compact

      blended_rate_per_kwhs.map { |rate| rate.round(2) }.minmax.uniq
    end
  end

  #=======================================================================================
  class BenchmarkContentChangeInBaseloadSinceLastYear < BenchmarkBaseloadBase
    include BenchmarkingNoTextMixin

    def introduction_text
      text = I18n.t('analytics.benchmarking.content.recent_change_in_baseload.introduction_text_html')
      text += I18n.t('analytics.benchmarking.caveat_text.es_exclude_storage_heaters_and_solar_pv')
      text += I18n.t('analytics.benchmarking.caveat_text.covid_lockdown')

      ERB.new(text).result(binding)
    end
  end
  #=======================================================================================
  class BenchmarkElectricityTarget < BenchmarkContentBase
    include BenchmarkingNoTextMixin

    private def introduction_text
      text = I18n.t('analytics.benchmarking.content.electricity_targets.introduction_text_html')
      ERB.new(text).result(binding)
    end
  end
    #=======================================================================================
    class BenchmarkGasTarget < BenchmarkContentBase
      include BenchmarkingNoTextMixin

      private def introduction_text
        text = I18n.t('analytics.benchmarking.content.gas_targets.introduction_text_html')
        ERB.new(text).result(binding)
      end
    end
  #=======================================================================================
  class BenchmarkContentBaseloadPerPupil < BenchmarkBaseloadBase
    include BenchmarkingNoTextMixin
    private def introduction_text
      text = I18n.t('analytics.benchmarking.content.baseload_per_pupil.introduction_text_html')
      text += I18n.t('analytics.benchmarking.caveat_text.es_exclude_storage_heaters_and_solar_pv')

      ERB.new(text).result(binding)
    end
  end

  #=======================================================================================
  class BenchmarkSeasonalBaseloadVariation < BenchmarkBaseloadBase
    include BenchmarkingNoTextMixin
    private def introduction_text
      text = I18n.t('analytics.benchmarking.content.seasonal_baseload_variation.introduction_text_html')
      text += I18n.t('analytics.benchmarking.caveat_text.es_exclude_storage_heaters_and_solar_pv')
      ERB.new(text).result(binding)
    end
  end

  #=======================================================================================
  class BenchmarkWeekdayBaseloadVariation < BenchmarkBaseloadBase
    include BenchmarkingNoTextMixin
    private def introduction_text
      text = I18n.t('analytics.benchmarking.content.weekday_baseload_variation.introduction_text_html')
      text += I18n.t('analytics.benchmarking.caveat_text.es_exclude_storage_heaters_and_solar_pv')
      ERB.new(text).result(binding)
    end
  end

  #=======================================================================================
  class BenchmarkContentPeakElectricityPerFloorArea < BenchmarkContentBase
    include BenchmarkingNoTextMixin
    private def introduction_text
      text = I18n.t('analytics.benchmarking.content.electricity_peak_kw_per_pupil.introduction_text_html')
      ERB.new(text).result(binding)
    end
  end
    #=======================================================================================
    class BenchmarkContentSolarPVBenefit < BenchmarkContentBase
      include BenchmarkingNoTextMixin
      private def introduction_text
        text = I18n.t('analytics.benchmarking.content.solar_pv_benefit_estimate.introduction_text_html')
        ERB.new(text).result(binding)
      end
    end
    #=======================================================================================
    class BenchmarkContentHeatingPerFloorArea < BenchmarkContentBase
      include BenchmarkingNoTextMixin
      private def introduction_text
        I18n.t('analytics.benchmarking.content.annual_heating_costs_per_floor_area.introduction_text_html')
      end
    end

  #=======================================================================================
  class BenchmarkContentGasOutOfHoursUsage < BenchmarkContentBase
    include BenchmarkingNoTextMixin

    private def introduction_text
      I18n.t('analytics.benchmarking.content.annual_gas_out_of_hours_use.introduction_text_html')
    end
  end
  #=======================================================================================
  class BenchmarkContentStorageHeaterOutOfHoursUsage < BenchmarkContentBase
    include BenchmarkingNoTextMixin
    private def introduction_text
      I18n.t('analytics.benchmarking.content.annual_storage_heater_out_of_hours_use.introduction_text_html')
    end
  end
  #=======================================================================================
  class BenchmarkContentThermostaticSensitivity < BenchmarkContentBase
    include BenchmarkingNoTextMixin
    private def introduction_text
      I18n.t('analytics.benchmarking.content.thermostat_sensitivity.introduction_text_html')
    end
  end
    #=======================================================================================
    class BenchmarkContentHeatingInWarmWeather < BenchmarkContentBase
      include BenchmarkingNoTextMixin
      private def introduction_text
        I18n.t('analytics.benchmarking.content.heating_in_warm_weather.introduction_text_html')
      end
    end
  #=======================================================================================
  class BenchmarkContentThermostaticControl < BenchmarkContentBase
    include BenchmarkingNoTextMixin
    private def introduction_text
      I18n.t('analytics.benchmarking.content.thermostatic_control.introduction_text_html')
    end
  end
  #=======================================================================================
  class BenchmarkContentHotWaterEfficiency < BenchmarkContentBase
    include BenchmarkingNoTextMixin
    private def introduction_text
      I18n.t('analytics.benchmarking.content.hot_water_efficiency.introduction_text_html')
    end
  end
  #=======================================================================================
  # 2 sets of charts, tables on one page
  class BenchmarkHeatingComingOnTooEarly < BenchmarkContentBase
    include BenchmarkingNoTextMixin
    private def introduction_text
      I18n.t('analytics.benchmarking.content.heating_coming_on_too_early.introduction_text_html')
    end

    def content(school_ids: nil, filter: nil, user_type: nil)
      content1 = super(school_ids: school_ids, filter: filter)
      content2 = optimum_start_content(school_ids: school_ids, filter: filter)
      content1 + content2
    end

    private

    def optimum_start_content(school_ids:, filter:)
      content_manager = Benchmarking::BenchmarkContentManager.new(@asof_date)
      db = @benchmark_manager.benchmark_database
      content_manager.content(db, :optimum_start_analysis, filter: filter)
    end
  end

  #=======================================================================================
  class BenchmarkContentEnergyPerFloorArea < BenchmarkContentBase
    # config key annual_energy_costs_per_floor_area
    include BenchmarkingNoTextMixin

    private def introduction_text
      text = '<p>'
      text += I18n.t('analytics.benchmarking.content.annual_energy_costs_per_floor_area.introduction_text_html')
      text += I18n.t('analytics.benchmarking.caveat_text.es_per_pupil_v_per_floor_area_useful_html')
      text += '</p>'
      ERB.new(text).result(binding)
    end
  end
  #=======================================================================================
  class BenchmarkContentChangeInEnergyUseSinceJoined < BenchmarkContentBase
    include BenchmarkingNoTextMixin

    private def introduction_text
      text = I18n.t('analytics.benchmarking.content.change_in_energy_use_since_joined_energy_sparks.introduction_text_html')
      text += I18n.t('analytics.benchmarking.caveat_text.covid_lockdown')

      ERB.new(text).result(binding)
    end
    protected def chart_interpretation_text
      text = I18n.t('analytics.benchmarking.content.change_in_energy_use_since_joined_energy_sparks.chart_interpretation_text_html')
      ERB.new(text).result(binding)
    end

    def content(school_ids: nil, filter: nil, user_type: nil)
      content1 = super(school_ids: school_ids, filter: filter)
      content2 = full_energy_change_breakdown(school_ids: school_ids, filter: filter)
      content1 + content2
    end

    private

    def full_energy_change_breakdown(school_ids:, filter:)
      content_manager = Benchmarking::BenchmarkContentManager.new(@asof_date)
      db = @benchmark_manager.benchmark_database
      content_manager.content(db, :change_in_energy_use_since_joined_energy_sparks_full_data, filter: filter)
    end
  end
  #=======================================================================================
  # shared wording save some translation costs
  class BenchmarkAnnualChangeBase < BenchmarkContentBase
  end
  #=======================================================================================
  class BenchmarkChangeInEnergySinceLastYear < BenchmarkAnnualChangeBase
    include BenchmarkingNoTextMixin

    private def introduction_text
      text = I18n.t('analytics.benchmarking.content.change_in_energy_since_last_year.introduction_text_html')
      text += I18n.t('analytics.benchmarking.caveat_text.covid_lockdown')
      ERB.new(text).result(binding)
    end

    def content(school_ids: nil, filter: nil, user_type: nil)
      content1 = super(school_ids: school_ids, filter: filter)
      # content2 = full_co2_breakdown(school_ids: school_ids, filter: filter)
      # content3 = full_energy_breakdown(school_ids: school_ids, filter: filter)
      content1 # + content2 + content3
    end

    private

    def full_co2_breakdown(school_ids:, filter:)
      content_manager = Benchmarking::BenchmarkContentManager.new(@asof_date)
      db = @benchmark_manager.benchmark_database
      content_manager.content(db, :change_in_co2_emissions_since_last_year_full_table, filter: filter)
    end

    def full_energy_breakdown(school_ids:, filter:)
      content_manager = Benchmarking::BenchmarkContentManager.new(@asof_date)
      db = @benchmark_manager.benchmark_database
      content_manager.content(db, :change_in_energy_since_last_year_full_table, filter: filter)
    end
  end
  #=======================================================================================
  class BenchmarkChangeInElectricitySinceLastYear < BenchmarkAnnualChangeBase
    include BenchmarkingNoTextMixin

    # some text duplication with the BenchmarkChangeInEnergySinceLastYear class
    private def introduction_text
      text = I18n.t('analytics.benchmarking.content.change_in_electricity_since_last_year.introduction_text_html')
      text += I18n.t('analytics.benchmarking.caveat_text.covid_lockdown')
      ERB.new(text).result(binding)
    end
  end
  #=======================================================================================
  class BenchmarkChangeInGasSinceLastYear < BenchmarkAnnualChangeBase
    include BenchmarkingNoTextMixin

    private def introduction_text
      text = I18n.t('analytics.benchmarking.content.change_in_gas_since_last_year.introduction_text_html')
      text += I18n.t('analytics.benchmarking.caveat_text.covid_lockdown')

      ERB.new(text).result(binding)
    end
  end
  #=======================================================================================
  class BenchmarkChangeInStorageHeatersSinceLastYear < BenchmarkAnnualChangeBase
    include BenchmarkingNoTextMixin

    private def introduction_text
      text = I18n.t('analytics.benchmarking.content.change_in_storage_heaters_since_last_year.introduction_text_html')
      text += I18n.t('analytics.benchmarking.caveat_text.covid_lockdown')
      ERB.new(text).result(binding)
    end
  end
  #=======================================================================================
  class BenchmarkChangeInSolarPVSinceLastYear < BenchmarkAnnualChangeBase
    include BenchmarkingNoTextMixin

    private def introduction_text
      text = I18n.t('analytics.benchmarking.content.change_in_solar_pv_since_last_year.introduction_text_html')
      ERB.new(text).result(binding)
    end
  end
  #=======================================================================================
  module BenchmarkPeriodChangeBaseElectricityMixIn
    def current_variable;     :current_pupils   end
    def previous_variable;    :previous_pupils  end
    def variable_type;        :pupils           end
    def has_changed_variable; :pupils_changed   end

    def change_rows_text(schools_to_sentence, period_type_string)
      I18n.t('analytics.benchmarking.content.footnotes.electricity.change_rows_text',
        period_type_string: period_type_string,
        schools_to_sentence: schools_to_sentence
      )
    end

    def infinite_increase_school_names_text(period_type_string)
      I18n.t('analytics.benchmarking.content.footnotes.electricity.infinite_increase_school_names_text',
        period_type_string: period_type_string)
    end

    def infinite_decrease_school_names_text(period_type_string)
      I18n.t('analytics.benchmarking.content.footnotes.electricity.infinite_decrease_school_names_text',
        period_type_string: period_type_string)
    end
  end

  module BenchmarkPeriodChangeBaseGasMixIn
    def current_variable;     :current_floor_area   end
    def previous_variable;    :previous_floor_area  end
    def variable_type;        :m2                   end
    def has_changed_variable; :floor_area_changed   end

    def change_rows_text(schools_to_sentence, period_type_string)
      I18n.t('analytics.benchmarking.content.footnotes.gas.change_rows_text',
        period_type_string: period_type_string,
        schools_to_sentence: schools_to_sentence
      )
    end

    def infinite_increase_school_names_text(period_type_string)
      I18n.t('analytics.benchmarking.content.footnotes.gas.infinite_increase_school_names_text',
        period_type_string: period_type_string)
    end

    def infinite_decrease_school_names_text(period_type_string)
      I18n.t('analytics.benchmarking.content.footnotes.gas.infinite_decrease_school_names_text',
        period_type_string: period_type_string)
    end
  end

  class BenchmarkPeriodChangeBase < BenchmarkContentBase
    include BenchmarkingNoTextMixin

    def content(school_ids: nil, filter: nil, user_type: nil)
      @rate_changed_in_period = calculate_rate_changed_in_period(school_ids, filter, user_type)
      super(school_ids: school_ids, filter: filter)
    end

    def footnote(school_ids, filter, user_type)
      raw_data = benchmark_manager.run_table_including_aggregate_columns(asof_date, page_name, school_ids, nil, filter, :raw, user_type)
      rows = raw_data.drop(1) # drop header

      return '' if rows.empty?

      floor_area_or_pupils_change_rows = changed_rows(rows, has_changed_variable)

      infinite_increase_school_names = school_names_by_calculation_issue(rows, :percent_changed, +Float::INFINITY)
      infinite_decrease_school_names = school_names_by_calculation_issue(rows, :percent_changed, -Float::INFINITY)

      changed = !floor_area_or_pupils_change_rows.empty? ||
                !infinite_increase_school_names.empty? ||
                !infinite_decrease_school_names.empty? ||
                @rate_changed_in_period

      return '' unless changed

      footnote_text_for(
        floor_area_or_pupils_change_rows,
        infinite_increase_school_names,
        infinite_decrease_school_names
      )
    end

    def footnote_text_for(floor_area_or_pupils_change_rows, infinite_increase_school_names, infinite_decrease_school_names)
      text = '<p>' + I18n.t('analytics.benchmarking.content.footnotes.notes') + ':<ul>'

      if floor_area_or_pupils_change_rows.present?
        text += change_rows_text(floor_area_or_pupils_change_rows.map { |row| school_name(row) }.sort.to_sentence, period_types)
      end

      if infinite_increase_school_names.present?
        text += infinite_increase_school_names_text(period_type)
      end

      if infinite_decrease_school_names.present?
        text += infinite_decrease_school_names_text(period_type)
      end

      if @rate_changed_in_period
        text += I18n.t('analytics.benchmarking.content.footnotes.rate_changed_in_period',
                       change_gbp_current_header: I18n.t('analytics.benchmarking.configuration.column_headings.change_£current')
                      )
      end

      text += '</ul></p>'

      ERB.new(text).result(binding)
    end

    def calculate_rate_changed_in_period(school_ids, filter, user_type)
      col_index = column_headings(school_ids, filter, user_type).index(I18n.t('analytics.benchmarking.configuration.column_headings.tariff_changed_period'))
      return false if col_index.nil?

      data = raw_data(school_ids, filter, user_type)
      return false if data.nil? || data.empty?

      rate_changed_in_periods = data.map { |row| row[col_index] }

      rate_changed_in_periods.any?
    end

    def school_names_by_calculation_issue(rows, column_id, value)
      rows.select { |row| row[table_column_index(column_id)] == value }
    end

    def school_names(rows)
      rows.map { |row| remove_references(row[table_column_index(:school_name)]) }
    end

    # reverses def referenced(name, changed, percent) in benchmark_manager.rb
    def remove_references(school_name)
      # puts "Before #{school_name} After #{school_name.gsub(/\(\*[[:blank:]]([[:digit:]]+,*)+\)/, '')}"
      school_name.gsub(/\(\*[[:blank:]]([[:digit:]]+,*)+\)/, '')
    end

    def changed_variable_column_index(change_variable)
      table_column_index(change_variable)
    end

    def changed?(row, change_variable)
      row[changed_variable_column_index(change_variable)] == true
    end

    def changed_rows(rows, change_variable)
      rows.select { |row| changed?(row, change_variable) }
    end

    def no_changes?(rows,  change_variable)
      rows.all?{ |row| !changed?(row, change_variable) }
    end

    def school_name(row)
      remove_references(row[table_column_index(:school_name)])
    end
  end
  #=======================================================================================
  class BenchmarkContentChangeInElectricityConsumptionSinceLastSchoolWeek < BenchmarkPeriodChangeBase
    include BenchmarkPeriodChangeBaseElectricityMixIn

    def period_type
      I18n.t('analytics.benchmarking.content.change_in_electricity_consumption_recent_school_weeks.period_type')
    end

    def period_types
      I18n.t('analytics.benchmarking.content.change_in_electricity_consumption_recent_school_weeks.period_types')
    end

    private def introduction_text
      text = I18n.t('analytics.benchmarking.content.change_in_electricity_consumption_recent_school_weeks.introduction_text_html')
      text += I18n.t('analytics.benchmarking.caveat_text.comparison_with_previous_period_infinite')
      ERB.new(text).result(binding)
    end


  end
  #=======================================================================================
  class BenchmarkHolidaysChangeBase < BenchmarkPeriodChangeBase
    def period_type
      I18n.t('analytics.benchmarking.content.benchmark_holidays_change_base.period_type')
    end

    def period_types
      I18n.t('analytics.benchmarking.content.benchmark_holidays_change_base.period_types')
    end
  end
  #=======================================================================================
  class BenchmarkContentChangeInElectricityBetweenLast2Holidays < BenchmarkHolidaysChangeBase
    include BenchmarkPeriodChangeBaseElectricityMixIn
    private def introduction_text
      text = I18n.t('analytics.benchmarking.content.change_in_electricity_holiday_consumption_previous_holiday.introduction_text_html')
      text += I18n.t('analytics.benchmarking.caveat_text.comparison_with_previous_period_infinite')
      ERB.new(text).result(binding)
    end
  end
  #=======================================================================================
  class BenchmarkContentChangeInElectricityBetween2HolidaysYearApart < BenchmarkHolidaysChangeBase
    include BenchmarkPeriodChangeBaseElectricityMixIn
    private def introduction_text
      text = I18n.t('analytics.benchmarking.content.change_in_electricity_holiday_consumption_previous_years_holiday.introduction_text_html')
      text += I18n.t('analytics.benchmarking.caveat_text.comparison_with_previous_period_infinite')
      ERB.new(text).result(binding)
    end
  end
  #=======================================================================================
  class BenchmarkContentChangeInGasConsumptionSinceLastSchoolWeek < BenchmarkHolidaysChangeBase
    include BenchmarkPeriodChangeBaseGasMixIn

    private def introduction_text
      text = I18n.t('analytics.benchmarking.content.change_in_gas_consumption_recent_school_weeks.introduction_text_html')
      text += I18n.t('analytics.benchmarking.caveat_text.comparison_with_previous_period_infinite')
      ERB.new(text).result(binding)
    end
  end
  #=======================================================================================
  class BenchmarkContentChangeInGasBetweenLast2Holidays < BenchmarkHolidaysChangeBase
    include BenchmarkPeriodChangeBaseGasMixIn

    private def introduction_text
      text = I18n.t('analytics.benchmarking.content.change_in_gas_holiday_consumption_previous_holiday.introduction_text_html')
      text +=  I18n.t('analytics.benchmarking.caveat_text.comparison_with_previous_period_infinite')
      ERB.new(text).result(binding)
    end
  end
  #=======================================================================================
  class BenchmarkContentChangeInGasBetween2HolidaysYearApart < BenchmarkHolidaysChangeBase
    include BenchmarkPeriodChangeBaseGasMixIn

    private def introduction_text
      text = I18n.t('analytics.benchmarking.content.change_in_gas_holiday_consumption_previous_years_holiday.introduction_text_html')
      text += I18n.t('analytics.benchmarking.caveat_text.comparison_with_previous_period_infinite')
      ERB.new(text).result(binding)
    end
  end
  #=======================================================================================
  class BenchmarkHeatingHotWaterOnDuringHolidayBase < BenchmarkContentBase
    include BenchmarkingNoTextMixin
  end

  class BenchmarkElectricityOnDuringHoliday < BenchmarkContentBase
    include BenchmarkingNoTextMixin
    private def introduction_text
      text = I18n.t('analytics.benchmarking.content.electricity_consumption_during_holiday.introduction_text_html')
      text += I18n.t('analytics.benchmarking.caveat_text.es_exclude_storage_heaters_and_solar_pv_data_html')
      ERB.new(text).result(binding)
    end
    def fuel
      I18n.t('analytics.common.electricity')
    end
  end

  class BenchmarkGasHeatingHotWaterOnDuringHoliday < BenchmarkHeatingHotWaterOnDuringHolidayBase
    include BenchmarkingNoTextMixin
    def introduction_text
      I18n.t('analytics.benchmarking.content.gas_consumption_during_holiday.introduction_text_html')
    end
    def fuel
      I18n.t('analytics.common.gas')
    end
  end

  class BenchmarkStorageHeatersOnDuringHoliday < BenchmarkHeatingHotWaterOnDuringHolidayBase
    include BenchmarkingNoTextMixin
    def introduction_text
      I18n.t('analytics.benchmarking.content.storage_heater_consumption_during_holiday.introduction_text_html')
    end
    def fuel
      I18n.t('analytics.common.storage_heaters')
    end
  end
  #=======================================================================================
  class BenchmarkEnergyConsumptionInUpcomingHolidayLastYear < BenchmarkContentBase
    include BenchmarkingNoTextMixin
    private def introduction_text
      text = I18n.t('analytics.benchmarking.content.holiday_usage_last_year.introduction_text_html')
      text += I18n.t('analytics.benchmarking.caveat_text.covid_lockdown')
      ERB.new(text).result(binding)
    end
  end
#=======================================================================================
  class BenchmarkChangeAdhocComparison < BenchmarkContentBase
    include BenchmarkingNoTextMixin
    private def introduction_text
      text = I18n.t('analytics.benchmarking.content.layer_up_powerdown_day_november_2022.introduction_text_html')
      ERB.new(text).result(binding)
    end

    # combine content of 4 tables: energy, electricity, gas, storage heaters
    def content(school_ids: nil, filter: nil, user_type: nil)
      content1 = super(school_ids: school_ids, filter: filter)
      content2 = electricity_content(school_ids: school_ids, filter: filter)
      content3 = gas_content(school_ids: school_ids, filter: filter)
      content4 = storage_heater_content(school_ids: school_ids, filter: filter)
      content1 + content2 + content3  + content4
    end

    private

    def electricity_content(school_ids:, filter:)
      extra_content(:layer_up_powerdown_day_november_2022_electricity_table, filter: filter)
    end

    def gas_content(school_ids:, filter:)
      extra_content(:layer_up_powerdown_day_november_2022_gas_table, filter: filter)
    end

    def storage_heater_content(school_ids:, filter:)
      extra_content(:layer_up_powerdown_day_november_2022_storage_heater_table, filter: filter)
    end

    def extra_content(type, filter:)
      content_manager = Benchmarking::BenchmarkContentManager.new(@asof_date)
      db = @benchmark_manager.benchmark_database
      content_manager.content(db, type, filter: filter)
    end
  end

  class BenchmarkChangeAdhocComparisonElectricityTable < BenchmarkContentBase
    include BenchmarkingNoTextMixin
  end

  class BenchmarkChangeAdhocComparisonGasTable < BenchmarkContentBase
    include BenchmarkingNoTextMixin
    private def introduction_text
      I18n.t('analytics.benchmarking.content.benchmark_change_adhoc_comparison_gas_table.introduction_text')
    end
  end

  class BenchmarkChangeAdhocComparisonStorageHeaterTable < BenchmarkChangeAdhocComparisonGasTable
    include BenchmarkingNoTextMixin
  end

  #=======================================================================================
  class BenchmarkAutumn2022Comparison < BenchmarkChangeAdhocComparison
    def electricity_content(school_ids:, filter:)
      extra_content(:autumn_term_2021_2022_electricity_table, filter: filter)
    end

    def gas_content(school_ids:, filter:)
      extra_content(:autumn_term_2021_2022_gas_table, filter: filter)
    end

    def storage_heater_content(school_ids:, filter:)
      extra_content(:autumn_term_2021_2022_storage_heater_table, filter: filter)
    end
  end

  class BenchmarkAutumn2022ElectricityTable < BenchmarkContentBase
    include BenchmarkingNoTextMixin
  end

  class BenchmarkAutumn2022GasTable < BenchmarkContentBase
    include BenchmarkingNoTextMixin

    private def introduction_text
      I18n.t('analytics.benchmarking.content.benchmark_autumn_2022_gas_table.introduction_text')
    end
  end

  class BenchmarkAutumn2022StorageHeaterTable < BenchmarkChangeAdhocComparisonGasTable
    include BenchmarkingNoTextMixin
  end

  #=======================================================================================
  class BenchmarkSeptNov2022Comparison < BenchmarkChangeAdhocComparison

    def electricity_content(school_ids:, filter:)
      extra_content(:sept_nov_2021_2022_electricity_table, filter: filter)
    end

    def gas_content(school_ids:, filter:)
      extra_content(:sept_nov_2021_2022_gas_table, filter: filter)
    end

    def storage_heater_content(school_ids:, filter:)
      extra_content(:sept_nov_2021_2022_storage_heater_table, filter: filter)
    end
  end

  class BenchmarkSeptNov2022ElectricityTable < BenchmarkContentBase
    include BenchmarkingNoTextMixin
  end

  class BenchmarkSeptNov2022GasTable < BenchmarkContentBase
    include BenchmarkingNoTextMixin

    private def introduction_text
      I18n.t('analytics.benchmarking.content.benchmark_sept_nov_2022_gas_table.introduction_text')
    end
  end

  class BenchmarkSeptNov2022StorageHeaterTable < BenchmarkChangeAdhocComparisonGasTable
    include BenchmarkingNoTextMixin
  end

  #=======================================================================================
  class BenchmarkEaster2023ShutdownComparison < BenchmarkChangeAdhocComparison

    def electricity_content(school_ids:, filter:)
      extra_content(:easter_shutdown_2023_electricity_table, filter: filter)
    end

    def gas_content(school_ids:, filter:)
      extra_content(:easter_shutdown_2023_gas_table, filter: filter)
    end

    def storage_heater_content(school_ids:, filter:)
      extra_content(:easter_shutdown_2023_storage_heater_table, filter: filter)
    end

    private def introduction_text
      text = I18n.t('analytics.benchmarking.content.easter_shutdown_2023_energy_comparison.introduction_text_html')
      ERB.new(text).result(binding)
    end

  end

  class BenchmarkEasterShutdown2023ElectricityTable < BenchmarkContentBase
    include BenchmarkingNoTextMixin
  end

  class BenchmarkEasterShutdown2023GasTable < BenchmarkContentBase
    include BenchmarkingNoTextMixin

    private def introduction_text
      I18n.t('analytics.benchmarking.content.benchmark_sept_nov_2022_gas_table.introduction_text')
    end
  end

  class BenchmarkEasterShutdown2023StorageHeaterTable < BenchmarkChangeAdhocComparisonGasTable
    include BenchmarkingNoTextMixin
  end

  #=======================================================================================
  class BenchmarkJanAugust20222023Comparison < BenchmarkChangeAdhocComparison

    def electricity_content(school_ids:, filter:)
      extra_content(:jan_august_2022_2023_electricity_table, filter: filter)
    end

    def gas_content(school_ids:, filter:)
      extra_content(:jan_august_2022_2023_gas_table, filter: filter)
    end

    def storage_heater_content(school_ids:, filter:)
      extra_content(:jan_august_2022_2023_storage_heater_table, filter: filter)
    end

    private def introduction_text
      text = I18n.t('analytics.benchmarking.content.jan_august_2023_2023_energy_comparison.introduction_text_html')
      ERB.new(text).result(binding)
    end

  end

  class BenchmarkJanAugust20222023ComparisonElectricityTable < BenchmarkContentBase
    include BenchmarkingNoTextMixin
  end

  class BenchmarkJanAugust20222023ComparisonGasTable < BenchmarkContentBase
    include BenchmarkingNoTextMixin

    private def introduction_text
      I18n.t('analytics.benchmarking.content.benchmark_jan_august_2022_2023_gas_table.introduction_text')
    end
  end

  class BenchmarkJanAugust20222023ComparisonStorageHeaterTable < BenchmarkChangeAdhocComparisonGasTable
    include BenchmarkingNoTextMixin
  end

  #========================================================================================
  class BenchmarkLayerUpPowerDownDay2023Comparison < BenchmarkChangeAdhocComparison

    def electricity_content(school_ids:, filter:)
      extra_content(:layer_up_powerdown_day_november_2023_electricity_table, filter: filter)
    end

    def gas_content(school_ids:, filter:)
      extra_content(:layer_up_powerdown_day_november_2023_gas_table, filter: filter)
    end

    def storage_heater_content(school_ids:, filter:)
      extra_content(:layer_up_powerdown_day_november_2023_storage_heater_table, filter: filter)
    end

    private def introduction_text
      text = I18n.t('analytics.benchmarking.content.layer_up_powerdown_day_november_2023.introduction_text_html')
      ERB.new(text).result(binding)
    end

  end

  class BenchmarkLayerUpPowerDownDay2023ComparisonElectricityTable < BenchmarkContentBase
    include BenchmarkingNoTextMixin
  end

  class BenchmarkLayerUpPowerDownDay2023ComparisonGasTable < BenchmarkContentBase
    include BenchmarkingNoTextMixin

    private def introduction_text
      I18n.t('analytics.benchmarking.content.benchmark_layer_up_powerdown_day_november_2023_gas_table.introduction_text')
    end
  end

  class BenchmarkLayerUpPowerDownDay2023ComparisonStorageHeaterTable < BenchmarkChangeAdhocComparisonGasTable
    include BenchmarkingNoTextMixin
  end
end
