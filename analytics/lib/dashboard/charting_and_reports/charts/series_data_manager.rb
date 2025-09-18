require_relative './../../../../app/models/open_close_times.rb'
# manages getting disperate sources of chart data as chart series
# typically by date range, or by half hour
module Series
  class ManagerBase
    include Logging
    attr_reader :school, :chart_config

    class UnexpectedSeriesManagerConfiguration < StandardError; end

    def initialize(school, chart_config)
      @school       = school
      @chart_config = chart_config
      process_temperature_adjustment_config
    end

    def self.factories(school, chart_config)
      series_breakdowns = [chart_config[:series_breakdown], chart_config[:y2_axis]].flatten
      series_breakdowns.map { |sb| factory(school, chart_config, sb) }.compact
    end

    def self.combined_series_names(series_classes)
      series_classes.map(&:series_names).flatten
    end

    def first_meter_date
      @first_meter_date ||= calculate_first_meter_date
    end

    def last_meter_date
      @last_meter_date ||= calculate_last_meter_date
    end

    def first_chart_date
      @first_chart_date ||= calculate_first_chart_date
    end

    def last_chart_date
      @last_chart_date ||= periods.first.end_date
    end

    def periods
      @periods ||= calculate_periods
    end

    def trendlines?
      chart_config.key?(:trendlines)
    end

    def self.series_name_for_trendline(trendline_name)
      trendline_name.to_s.sub('trendline_', '' ).to_sym
    end

    def meter
      @meter ||= determine_meter
    end

    def ignore_missing_amr_data?
      meter.is_a?(TargetMeter)
    end

    def kwh_cost_or_co2
      case chart_config[:yaxis_units]
      when :£;               :economic_cost
      when :£current;        :current_economic_cost
      when :accounting_cost; :accounting_cost
      when :co2;             :co2
      else;                  :kwh
      end
    end

    def trendlines
      chart_config[:trendlines].map { |series_name| self.class.trendline_for_series_name(series_name) }
    end

    def self.y2_series_types
      {
        degreedays:           DegreeDays::DEGREEDAYS,
        temperature:          Temperature::TEMPERATURE,
        irradiance:           Irradiance::IRRADIANCE,
        gridcarbon:           GridCarbon::GRIDCARBON,
        gascarbon:            GasCarbon::GASCARBON,
        target_degreedays:    TargetDegreeDays::TARGETDEGREEDAYS
      }
    end

    private

    private_class_method def self.factory(school, chart_config, series_breakdown_type)
      class_map = {
        boiler_start_time:  BoilerStartTime,
        temperature:        Temperature,
        degreedays:         DegreeDays,
        irradiance:         Irradiance,
        gridcarbon:         GridCarbon,
        gascarbon:          GasCarbon,
        daytype:            DayType,
        heating:            HeatingNonHeating,
        heating_daytype:    HeatingDayType,
        meter:              MeterBreakdown,
        submeter:           SubMeterBreakdown,
        model_type:         ModelType,
        hotwater:           HotWater,
        cusum:              Cusum,
        baseload:           Baseload,
        peak_kw:            PeakKw,
        predictedheat:      PredictedHeat,
        target_degreedays:  TargetDegreeDays,
        none:               NoBreakdown,
        fuel:               MultipleFuels,
        accounting_cost:    AccountingCost
      }

      return nil unless class_map.key?(series_breakdown_type)

      class_map[series_breakdown_type].new(school, chart_config)
    end

    def determine_meter
      ChartToMeterMap.instance.meter(school, chart_config[:meter_definition], chart_config[:sub_meter_definition])
    end

    def series_names
      [self.class.name.gsub!(/(.)([A-Z])/,'\1_\2').downcase.to_sym]
    end

    def day_breakdown(_date1, _date2)
      raise EnergySparksAbstractBaseClass, "Unsupported day_breakdown request for #{self.class.name}"
    end

    def half_hour_breakdown(_date, _half_hour_index)
      raise EnergySparksAbstractBaseClass, "Unsupported half_hour_breakdown request for #{self.class.name}"
    end

    def humanize(names)
      if names.is_a?(Array)
        names.map(&:to_s).map(&:humanize)
      else
        names.to_s.humanize
      end
    end

    def default_breakdown(bdown = series_names, val = 0.0)
      bdown.map { |type_str| [type_str, val] }.to_h
    end

    def community_use
      if @calculated_community_use.nil? # as @community_use can be nil, for speed
        @community_use = calculate_community_use
        @calculated_community_use = true
      end
      @community_use
    end

    def calculate_community_use
      if chart_config.key?(:community_use)
        chart_config[:community_use]
      elsif chart_config[:series_breakdown] == :daytype
        # backwards compatibility, day type break down charts have single 'community' aggregate usage
        { filter: :all, aggregate: :community_use }
      else
        nil
      end
    end

    def missing_data
      nil
    end

    def amr_data_by_half_hour(meter, date, halfhour_index, data_type = :kwh)
      return missing_data if ignore_missing_amr_data? && !meter.amr_data.date_exists?(date)

      return nil if target_truncate_before_start_date? && date < target_start_date(meter)

      meter.amr_data.kwh(date, halfhour_index, data_type, community_use: community_use)
    end

    def amr_data_one_day_readings(meter, date, data_type = :kwh)
      meter.amr_data.days_kwh_x48(date, data_type, community_use: community_use)
    end

    def amr_data_one_day(meter, date, data_type = :kwh)
      meter.amr_data.one_day_kwh(date, data_type, community_use: community_use)
    end

    def single_name; nil end

    def target_school
      @school.target_school? ? @school : @school.target_school(target_calculation_type)
    end

    def target_meter(meter)
      original_school = school.target_school? ? @school : @school.target_school(target_calculation_type)
      target_school.aggregate_meter(meter.fuel_type)
    end

    # only call if dealing with target meter, else will force expensive
    # lazy target meter calculation
    def target_start_date(meter)
      target_meter(meter).target_dates.target_start_date
    end

    def amr_data_date_range(meter, start_date, end_date, data_type)

      if target_truncate_before_start_date?
        start_date = [start_date, target_start_date(meter)].max
        return nil if start_date > end_date
      end

      if @adjust_by_temperature && meter.fuel_type == :gas
        adjust_for_temperature(meter, start_date, end_date, data_type)
      elsif ignore_missing_amr_data?
        values = (start_date..end_date).map do |date|
          meter.amr_data.date_exists?(date) ? meter.amr_data.one_day_kwh(date, data_type, community_use: community_use) : missing_data
        end

        if values.all?{ |v| v == missing_data }
          missing_data
        else
          values.map { |v| v == missing_data ? 0.0 : v }.sum
        end
      elsif override_meter_end_date?
        total = 0.0
        (start_date..end_date).each do |date|
          total += date > meter.amr_data.end_date ? 0.0 : meter.amr_data.one_day_kwh(date, data_type, community_use: community_use)
        end
        total
      else
        meter.amr_data.kwh_date_range(start_date, end_date, data_type, community_use: community_use)
      end
    end

    def adjust_for_temperature(meter, start_date, end_date, data_type)
      dates = (start_date..end_date).to_a
      kwhs = dates.map { |date| meter.amr_data.one_day_kwh(date, data_type, community_use: community_use) }
      scale = scaling_factor_for_model_derived_gas_data(data_type)
      adj_temperatures = adjustment_temperatures(dates)

      total_adjusted_kwh = 0.0
      (start_date..end_date).each_with_index do |date, i|
        total_adjusted_kwh += heating_model.temperature_compensated_one_day_gas_kwh(date, adj_temperatures[i], kwhs[i], 0.0, community_use: community_use)
      end
      total_adjusted_kwh
    end

    def scaling_factor_for_model_derived_gas_data(data_type)
      case data_type
      when :£, :economic_cost;                meter.amr_data.current_tariff_rate_£_per_kwh
      when :£current, :current_economic_cost; meter.amr_data.current_tariff_rate_£_per_kwh
      when :accounting_cost;                  raise EnergySparksUnexpectedStateException, 'scaling factor requested for accounting tariff'
      when :co2;                              EnergyEquivalences.co2_kg_kwh(:gas)
      else;                                   1.0
      end
    end

    def adjustment_temperatures(dates)
      if @adjust_by_temperature_value.is_a?(Float)
        Array.new(dates.length, @adjust_by_temperature_value)
      elsif !@adjust_by_average_temperature.nil?
        Array.new(dates.length, @adjust_by_average_temperature)
      elsif @adjust_by_temperature_value.is_a?(Hash)
        dates.map{ |date| @adjust_by_temperature_value[date] }
      else
        raise EnergySparksUnexpectedStateException, "Expecting Float or Hash for @adjust_by_temperature_value when @adjust_by_temperature true: #{@adjust_by_temperature_value}"
      end
    end

    def override_meter_end_date?
      chart_config.key?(:calendar_picker_allow_up_to_1_week_past_last_meter_date)
    end

    def process_temperature_adjustment_config
      if chart_config.key?(:adjust_by_temperature)
        @adjust_by_temperature = true
        if chart_config[:adjust_by_temperature].is_a?(Float)
          @adjust_by_temperature_value = chart_config[:adjust_by_temperature]
        elsif chart_config[:adjust_by_temperature].is_a?(Hash)
          @adjust_by_temperature_value = chart_config[:temperature_adjustment_map]
        else
          raise EnergySparksBadChartSpecification, 'Unexpected temperature adjustment type'
        end
      end
      if chart_config.key?(:adjust_by_average_temperature)
        if chart_config[:adjust_by_average_temperature].is_a?(Hash)
          temperatures = adjusted_temperature_values_for_period(chart_config[:adjust_by_average_temperature])
          @adjust_by_average_temperature = temperatures.sum / temperatures.length
          @adjust_by_temperature = true
        else
          raise EnergySparksBadChartSpecification, 'Unexpected average temperature adjustment type'
        end
      end
    end

    def self.trendline_for_series_name(series_name)
      ('trendline_' + series_name.to_s).to_sym
    end

    def target_extend?
      chart_config.dig(:target, :extend_chart_into_future) == true
    end

    def target_truncate_before_start_date?
      chart_config.dig(:target, :truncate_before_start_date) == true
    end

    def target_calculation_type
      chart_config.dig(:target, :calculation_type)
    end

    # truncate requested dates to non-target meter range or return nil
    def target_extended_other_meter_end_date(meter, start_date, end_date)
      end_date = [meter.amr_data.end_date, end_date].min
      start_date > end_date ? [nil, nil] : [start_date, end_date]
    end

    def request_start_end_dates(meter, start_date, end_date)
      target_extend? ? target_extended_other_meter_end_date(meter, start_date, end_date) : [start_date, end_date]
    end

    def check_requested_meter_date(meters, start_date, end_date)
      return if ignore_missing_amr_data?
      # TODO(PH, 11Mar2022) - perhaps revisit as pre-refactor implementation only selected one meter for this test
      [meters].flatten.compact.each do |meter|
        if start_date < meter.amr_data.start_date || end_date > meter.amr_data.end_date
          requested_dates = start_date == end_date ? "requested data for #{start_date}" : "requested data from #{start_date} to #{end_date}"
          meter_dates = "meter from #{meter.amr_data.start_date} to #{meter.amr_data.end_date}: "
          raise EnergySparksNotEnoughDataException, "Not enough data for chart aggregation: #{meter_dates} #{requested_dates}"
        end
      end
    end

    def calculate_periods
      period_calc = PeriodsBase.period_factory(chart_config, school, first_meter_date, last_meter_date)
      @periods = period_calc.periods
    end

    def calculate_first_chart_date
      nil_period_count = periods.count(&:nil?)
      raise EnergySparksNotEnoughDataException, "Not enough data for chart (nil period x#{nil_period_count})" if nil_period_count > 0 || periods.length == 0
      periods.last.start_date # years in reverse chronological order
    end

    def y2_axis_uses_temperatures?
      %i[temperature degreedays].include?(chart_config[:y2_axis])
    end

    def y2_axis_uses_solar_irradiance?
      chart_config[:y2_axis] == :irradiance
    end

    def calculate_first_meter_date
      meter_date = [meter].flatten.compact.map { |m| m.amr_data.start_date }.max

      if y2_axis_uses_temperatures? && school.temperatures.start_date > meter_date
        logger.info "Reducing meter range because temperature axis with less data on chart #{meter_date} versus #{school.temperatures.start_date}"
        meter_date = school.temperatures.start_date
      end

      if y2_axis_uses_solar_irradiance? && school.solar_irradiation.start_date > meter_date
        logger.info "Reducing meter range because irradiance axis with less data on chart #{meter_date} versus #{school.solar_irradiation.start_date}"
        meter_date = school.solar_irradiation.start_date
      end

      meter_date = chart_config[:min_combined_school_date] if chart_config.key?(:min_combined_school_date)
      meter_date
    end

    def calculate_last_meter_date
      meter_date = [meter].flatten.compact.map{ |m| m.amr_data.end_date }.min

      if y2_axis_uses_temperatures? && school.temperatures.end_date < meter_date
        logger.info "Reducing meter rage becausne temperature axis with less data on chart #{meter_date} versus #{school.temperatures.end_date}"
        meter_date = school.temperatures.end_date # this may not be strict enough?
      end

      if y2_axis_uses_solar_irradiance? && school.solar_irradiation.end_date < meter_date
        logger.info "Reducing meter range because irradiance axis with less data on chart #{meter_date} versus #{school.solar_irradiation.end_date}"
        meter_date = school.solar_irradiation.end_date # this may not be strict enough?
      end

      meter_date = chart_config[:max_combined_school_date] if chart_config.key?(:max_combined_school_date)
      meter_date = chart_config[:asof_date] if chart_config.key?(:asof_date)
      meter_date
    end
  end

  #=====================================================================================================
  class Multiple < ManagerBase
    class TooManyMeters < StandardError;  end
    def initialize(school, chart_config)
      super(school, chart_config)
      @series_managers = Series::ManagerBase.factories(school, chart_config)
    end

    def series_bucket_names
      Series::ManagerBase.combined_series_names(@series_managers).uniq
    end

    def heating_model
      @series_managers.each do |series_manager|
        return series_manager.heating_model if series_manager.is_a?(ModelManagerBase)
      end

      nil
    end

    def model_type?(date)
      heating_model.model_type?(date)
    end

    def predicted_amr_data_one_day(date)
      temperature = school.temperatures.average_temperature(date)
      scale_datatype_from_kwh(date, heating_model.predicted_kwh(date, temperature))
    end

    def scale_datatype_from_kwh(date, kwh)
      case kwh_cost_or_co2
      when :kwh
        kwh
      when :£, :£current
        # just use currently blended rate as there may not be a rate fopr today
        # if kWh = 0.0 but model still calculates?
        kwh * meter.amr_data.current_tariff_rate_£_per_kwh
      when :co2
        kwh * meter.amr_data.average_co2_intensity_kwh_kg(date)
      end
    end

    def heating_model_types
      heating_model.all_heating_model_types
    end

    def get_data(time_period)
      data_private(time_period)
    end

    def get_one_days_data_x48(date, type = :kwh)
      raise TooManyMeters, 'Shouldnt be an array of meters for this type of request' if meter.is_a?(Array)
      check_requested_meter_date(meter, date, date) # non optimal request
      amr_data_one_day_readings(meter, date, type)
    end

    private

    def half_hour_breakdown(date, halfhour_index)
      breakdown = {}

      @series_managers.each do |series_manager|
        breakdown.merge!(series_manager.half_hour_breakdown(date, halfhour_index))
      end

      breakdown
    end

    def day_breakdown( d1, d2)
      breakdown = {}

      @series_managers.each do |series_manager|
        breakdown.merge!(series_manager.day_breakdown(d1, d2))
      end

      breakdown
    end

    def data_private(time_period)
      breakdown = {}

      timetype, dates, hhi = time_period

      case timetype
      when :halfhour, :datetime
        check_requested_meter_date(meter, dates, dates)
        breakdown = half_hour_breakdown(dates, hhi)
      when :daterange
        start_date, end_date = request_start_end_dates(meter, dates[0], dates[1])
        unless start_date.nil?
          check_requested_meter_date(meter, start_date, end_date) unless override_meter_end_date?
          breakdown = day_breakdown(start_date, end_date)
        end
      end

      breakdown
    end
  end

  #=====================================================================================================
  class Temperature < ManagerBase
    TEMPERATURE = 'Temperature'
    TEMPERATURE_I18N_KEY = 'temperature'
    def series_names;                    [single_name]; end
    def day_breakdown(d1, d2);           { single_name => school.temperatures.average_temperature_in_date_range(d1, d2) }; end
    def half_hour_breakdown(date, hhi);  { single_name => school.temperatures.temperature(date, hhi) }; end
    private
    def single_name; TEMPERATURE end
  end

  #=====================================================================================================
  class Irradiance < ManagerBase
    IRRADIANCE = 'Solar Irradiance'
    IRRADIANCE_I18N_KEY = 'solar_irradiance'

    def series_names;                    [single_name]; end
    def day_breakdown(d1, d2);           { single_name => school.solar_irradiation.average_daytime_irradiance_in_date_range(d1, d2) }; end
    def half_hour_breakdown(date, hhi);  { single_name => school.solar_irradiation.solar_irradiance(date, hhi) }; end
    private
    def single_name; IRRADIANCE end
  end

  #=====================================================================================================
  class GridCarbon < ManagerBase
    GRIDCARBON = 'Carbon Intensity of Electricity Grid (kg/kWh)'
    GRIDCARBON_I18N_KEY = 'gridcarbon'

    def series_names;                    [single_name]; end
    def day_breakdown(d1, d2);           { single_name => school.grid_carbon_intensity.average_in_date_range(d1, d2) }; end
    def half_hour_breakdown(date, hhi);  { single_name => school.grid_carbon_intensity.grid_carbon_intensity(date, hhi) }; end
    private
    def single_name; GRIDCARBON end
  end

  #=====================================================================================================
  class GasCarbon < ManagerBase
    GASCARBON = 'Carbon Intensity of Gas (kg/kWh)'
    GASCARBON_I18N_KEY = 'gascarbon'

    def series_names;                     [single_name]; end
    def day_breakdown(_d1, _d2);          { single_name => EnergyEquivalences.co2_kg_kwh(:gas) }; end
    def half_hour_breakdown(_date, _hhi); { single_name => EnergyEquivalences.co2_kg_kwh(:gas) }; end
    private
    def single_name; GASCARBON end
  end

  #=====================================================================================================
  class MeterBreakdown < ManagerBase
    def initialize(school, chart_config)
      super(school, chart_config)
      configure_meters
    end

    def series_names; meter_names; end

    def half_hour_breakdown(date, hhi);  { single_name => school.solar_irradiation.solar_irradiance(date, hhi) }; end

    def day_breakdown(d1, d2)
      breakdown = default_breakdown
      @component_meters.each do |component_meter|
        sd, ed, ok = truncated_date_range(component_meter, d1, d2)
        series_name = @meter_to_series_names[component_meter]
        breakdown[series_name] = amr_data_date_range(component_meter, sd, ed, kwh_cost_or_co2) if ok
      end
      breakdown
    end

    def half_hour_breakdown(date, hhi)
      breakdown = default_breakdown

      @component_meters.each do |component_meter|
        sd, ed, ok = truncated_date_range(component_meter, date, date)
        series_name = @meter_to_series_names[component_meter]
        breakdown[series_name] = amr_data_by_half_hour(component_meter, date, hhi, kwh_cost_or_co2) if ok
      end

      breakdown
    end

    private

    def meter_to_series_names
      name_count = @component_meters.map(&:series_name).tally
      @component_meters.map { |m| [m, name_count[m.series_name] > 1 ? m.qualified_series_name : m.series_name] }.to_h
    end

    def configure_meters
      if meter.fuel_type == :electricity
        @aggregate_meter  = school.aggregated_electricity_meters
        @component_meters = school.electricity_meters
      else
        @aggregate_meter  = school.aggregated_heat_meters
        @component_meters = [school.heat_meters, school.storage_heater_meters].flatten
      end
      @meter_to_series_names = meter_to_series_names
    end

    def meter_names
      @meter_to_series_names.values
    end

    def truncated_date_range(component_meter, start_date, end_date)
      start_date = [start_date, @aggregate_meter.amr_data.start_date, component_meter.amr_data.start_date].max
      end_date   = [end_date,   @aggregate_meter.amr_data.end_date,   component_meter.amr_data.end_date  ].min
      [start_date, end_date, start_date <= end_date]
    end
  end

  #=====================================================================================================
  class SubMeterBreakdown < MeterBreakdown
    private

    def configure_meters
      @aggregate_meter  = meter
      @component_meters = meter.sub_meters.values
      @meter_to_series_names = meter_to_series_names
    end
  end

  #=====================================================================================================
  class DayType < ManagerBase
    HOLIDAY         = OpenCloseTime.humanize_symbol(OpenCloseTime::HOLIDAY)
    WEEKEND         = OpenCloseTime.humanize_symbol(OpenCloseTime::WEEKEND)
    SCHOOLDAYOPEN   = OpenCloseTime.humanize_symbol(OpenCloseTime::SCHOOL_OPEN)
    SCHOOLDAYCLOSED = OpenCloseTime.humanize_symbol(OpenCloseTime::SCHOOL_CLOSED)
    STORAGE_HEATER_CHARGE = 'Storage heater charge (school day)'

    SCHOOLDAYCLOSED_I18N_KEY = 'school_day_closed'
    SCHOOLDAYOPEN_I18N_KEY = 'school_day_open'
    HOLIDAY_I18N_KEY = 'holiday'
    WEEKEND_I18N_KEY = 'weekend'
    STORAGE_HEATER_CHARGE_I18N_KEY = 'storage_heater_charge'

    def series_names;                   day_type_names; end
    def day_breakdown(d1, d2);          daytype_breakdown(d1, d2); end
    def half_hour_breakdown(date, hhi); daytype_breakdown_halfhour(date, hhi); end

    private

    def day_type_names
      @day_type_names ||= calculate_day_type_names
    end

    def calculate_day_type_names
      types = meter.amr_data.open_close_breakdown.series_names(community_use)
      types.uniq.sort_by { |type| - OpenCloseTime.community_use_types[type][:sort_order] }
    end

    def daytype_breakdown_halfhour(date, halfhour_index)
      daytype_data = default_breakdown

      breakdown = meter.amr_data.kwh(date, halfhour_index, kwh_cost_or_co2, community_use: community_use)

      breakdown.each do |type, kwh|
        daytype_data[type] = kwh
      end

      daytype_data
    end

    def daytype_breakdown(d1, d2)
      daytype_data = default_breakdown
      data_type = kwh_cost_or_co2

      (d1..d2).each do |date|
        begin
          breakdown = meter.amr_data.one_day_kwh(date, data_type, community_use: community_use)

          breakdown.each do |type, kwh|
            daytype_data[type] += kwh
          end
        end
      end

      daytype_data
    end
  end

  #=====================================================================================================
  class ModelManagerBase < ManagerBase

    def heating_model
      heating_model_type     = chart_config[:model] || :best
      non_heating_model_type = chart_config[:non_heating_model]
      period                 = meter.up_to_one_year_model_period

      @heating_model ||= meter.heating_model(period, heating_model_type, non_heating_model_type)
    end

    def model_type?(date)
      heating_model.model_type?(date)
    end

    private

    def degreeday_base_temperature; 15.5 end
  end

  #=====================================================================================================
  class DegreeDays < ModelManagerBase
    DEGREEDAYS = 'Degree Days'
    DEGREEDAYS_I18N_KEY = 'degree_days'

    def series_names;                    [single_name]; end
    def day_breakdown(d1, d2);           { single_name => school.temperatures.degrees_days_average_in_range(degreeday_base_temperature, d1, d2) }; end
    def half_hour_breakdown(date, hhi);  { single_name => school.temperatures.degree_hour(date, hhi, degreeday_base_temperature) }; end
    private
    def single_name; DEGREEDAYS end
  end

  #=====================================================================================================
  class BoilerStartTime < ModelManagerBase
    def series_names;         %i[boiler_start_time]; end
    def day_breakdown(d1, d2)
      raise UnexpectedSeriesManagerConfiguration, "Date range not supported #{d1} #{d2}" if d1 != d2
      hhi = heating_model.heating_on_half_hour_index_checked(d1, ignore_frosty_days_temperature: filter_out_frost_temperature)
      { boiler_start_time: hhi * 0.5 }
    end

    def filter_out_frost_temperature
      chart_config.dig(:boiler_start_time, :ignore_frosty_days_temperature)
    end
  end

  #=====================================================================================================
  class HeatingNonHeating < ModelManagerBase
    HEATINGDAY              = 'Heating on in cold weather'.freeze
    NONHEATINGDAY           = 'Hot Water (& Kitchen)'.freeze
    HEATINGDAYWARMWEATHER   = 'Heating on in warm weather'.freeze

    HEATINGDAY_I18N_KEY = 'heating_day'
    NONHEATINGDAY_I18N_KEY = 'non_heating_day'
    HEATINGDAYWARMWEATHER_I18N_KEY = 'heating_day_warm_weather'

    def series_names;  [HEATINGDAYWARMWEATHER, HEATINGDAY, NONHEATINGDAY]; end

    def day_breakdown(start_date, end_date)
      heating_data = default_breakdown

      (start_date..end_date).each do |date|
        begin
          breakdown_data = heating_model.heating_breakdown(date, kwh_cost_or_co2)

          breakdown_data.each do |heating_type, val_kwh_co2_or_£|
            readable_type = humanize_heating_type(heating_type)
            heating_data[readable_type] += val_kwh_co2_or_£
          end
        rescue StandardError => e
          logger.error e
          logger.error "Warning: unable to calculate heating breakdown on #{date}"
        end
      end

      heating_data
    end

    private

    def humanize_heating_type(type)
      case type
      when :heating_warm_weather
        HEATINGDAYWARMWEATHER
      when :heating_cold_weather
        HEATINGDAY
      when :heating_off
        NONHEATINGDAY
      end
    end
  end

  #=====================================================================================================
  class ModelType < ModelManagerBase
    def series_names;  heating_model.all_heating_model_types; end

    # this breakdown uses NaN to indicate missing data, so Excel doesn't plot it
    def day_breakdown(d1, d2)
      # TODO(PH, 11Mar2022) should this be 0.0, or Float::NAN or nil?
      #                     during refactor it appears this function
      #                     is only called a day at a time
      #                     so not sure how default bucket values work
      breakdown = {} #  default_breakdown(series_names, Float::NAN)

      (d1..d2).each do |date|
        type = heating_model.model_type?(date)

        if breakdown[type].nil? || breakdown[type].nan?
          breakdown[type] = amr_data_one_day(meter, date, kwh_cost_or_co2)
        else
          breakdown[type] += amr_data_one_day(meter, date, kwh_cost_or_co2)
        end
      end

      breakdown
    end
  end

  #=====================================================================================================
  class HotWater < ModelManagerBase
    USEFULHOTWATERUSAGE = 'Hot Water Usage'
    WASTEDHOTWATERUSAGE = 'Wasted Hot Water Usage'
    HOTWATERSERIESNAMES = [USEFULHOTWATERUSAGE, WASTEDHOTWATERUSAGE]

    USEFULHOTWATERUSAGE_I18N_KEY = 'useful_hot_water_usage'
    WASTEDHOTWATERUSAGE_I18N_KEY = 'wasted_hot_water_usage'

    def series_names;  HOTWATERSERIESNAMES; end

    def day_breakdown(d1, d2)
      breakdown = {}
      scale = scaling_factor_for_model_derived_gas_data(kwh_cost_or_co2)
      useful_kwh, wasted_kwh = hotwater_model.kwh_daterange(d1, d2)
      breakdown[USEFULHOTWATERUSAGE] = useful_kwh * scale
      breakdown[WASTEDHOTWATERUSAGE] = wasted_kwh * scale
      breakdown
    end

    def hotwater_model
      @hotwater_model ||= AnalyseHeatingAndHotWater::HotwaterModel.new(school)
    end
  end

  #=====================================================================================================
  class NoBreakdown < ModelManagerBase
    NONE = 'Energy'
    NONE_I18N_KEY = 'none'

    def series_names;  [NONE]; end

    def day_breakdown(d1, d2)
      { NONE => amr_data_date_range(meter, d1, d2, kwh_cost_or_co2) }
    end

    def half_hour_breakdown(date, hhi)
      { NONE => amr_data_by_half_hour(meter, date, hhi, kwh_cost_or_co2) }
    end
  end

  #=====================================================================================================
  class AccountingCost < ManagerBase

    #Charts showing accounting costs need to use the original underlying meters
    #when we are using electricity data, otherwise we can end up include solar
    #self-consumption in the cost calculations.
    #
    #Override the method to determine the meter to handle a couple of scenarios
    #
    #If we are just running a chart with a generic meter specification, then
    #delegate to base class. This allows us to set this in chart config:
    #
    # meter_definition:  :allelectricity_unmodified
    #
    #But sometimes we are running charts with for a specific real or synthetic
    #mpan. This is used for per-meter cost charts and, as it happens, the aggregate
    #cost chart in the application.
    #
    #In this case we need to use alternative approach to finding the right meter
    def determine_meter
      #Just return super if its a generic meter specification
      return super if chart_config[:meter_definition].is_a? Symbol
      #Find the meter
      meter = @school.meter?(chart_config[:meter_definition], true)
      #Check whether there's an underlying meter. If there isn't then just
      #use this meter.
      return meter unless meter.sub_meters.key?(:mains_consume) && !meter.sub_meters[:mains_consume].nil?
      #Return the original meter. Should only end up being called for
      #gas and electric meters
      meter.original_meter
    end

    def series_names
      #Need to use the aggregate meter to get bill components? If using a sub meter
      #then the list of components may sometimes be empty? E.g. fails if there's a single electricity
      #meter + solar
      @school.aggregate_meter(meter.fuel_type).amr_data.accounting_tariff.bill_component_types.uniq
    end

    def half_hour_breakdown(date, hhi)
      meter.amr_data.accounting_tariff.cost_data_halfhour_broken_down(date, hhi)
    end

    def day_breakdown(d1, d2)
      bill_components = default_breakdown

      (d1..d2).each do |date|
        components = meter.amr_data.accounting_tariff.bill_component_costs_for_day(date)
        components.each do |type, value|
          if bill_components[type] == nil
            bill_components[type] = value
          else
            bill_components[type] += value
          end
        end
      end

      bill_components
    end
  end

  #=====================================================================================================
  class MultipleFuels < ModelManagerBase
    ELECTRICITY      = 'electricity'
    GAS              = 'gas'
    STORAGEHEATERS   = 'storage heaters'
    SOLARPV          = 'solar pv (consumed onsite)' # think unused?

    ELECTRICITY_I18N_KEY      = 'electricity'
    GAS_I18N_KEY              = 'gas'
    STORAGEHEATERS_I18N_KEY   = 'storage_heaters'
    SOLARPV_I18N_KEY          = 'solar_pv' # think unused?

    def series_names
      #If the chart config specifies a specific meter then we should only
      #add series for that fuel type. Otherwise assume all fuel types are
      #required.
      #
      #This was added to allow the benchmarking charts to work with specific
      #fuel types
      return [GAS] if @chart_config[:meter_definition] == :allheat
      return [ELECTRICITY] if @chart_config[:meter_definition] == :allelectricity
      return [STORAGEHEATERS] if @chart_config[:meter_definition] == :storage_heater_meter
      aggregate_meters.keys
    end

    def half_hour_breakdown(date, hhi)
      breakdown = default_breakdown

      breakdown.each do |fuel_type_str|
        next if aggregate_meters[fuel_type_str].nil?

        breakdown[fuel_type_str] = amr_data_by_half_hour(aggregate_meters[fuel_type_str], date, hhi, kwh_cost_or_co2)
      end

      breakdown
    end

    def day_breakdown(d1, d2)
      breakdown = default_breakdown

      (d1..d2).each do |date|
        breakdown.keys.each do |fuel_type_str|
          next if aggregate_meters[fuel_type_str].nil?

          # skip if we don't have any data for this day. fixes issue if the date ranges for the
          # fuel types don't align, e.g. if we only have storage heater data for a historical period
          next unless aggregate_meters[fuel_type_str].amr_data.date_exists_by_type?(date, :kwh)

          breakdown[fuel_type_str] += amr_data_one_day(aggregate_meters[fuel_type_str], date, kwh_cost_or_co2)
        end
      end

      breakdown
    end

    private

    def aggregate_meters
      @aggregate_meters || calculate_aggregate_meters
    end

    def calculate_aggregate_meters
      meters = {
        ELECTRICITY => school.aggregated_electricity_meters,
        GAS         => school.aggregated_heat_meters,
      }
      meters[STORAGEHEATERS] = school.storage_heater_meter if school.storage_heaters?

      meters
    end
  end

  #=====================================================================================================
  class PredictedHeat < ModelManagerBase
    PREDICTEDHEAT = 'Predicted Heat'
    PREDICTEDHEAT_I18N_KEY = 'predicted_heat'

    def series_names;  [PREDICTEDHEAT]; end

    def day_breakdown(d1, d2)
      { PREDICTEDHEAT => heating_model.predicted_kwh_daterange(d1, d2, school.temperatures) }
    end
  end

  #=====================================================================================================
  class TargetDegreeDays < ModelManagerBase
    TARGETDEGREEDAYS = 'Target degree days'
    TARGETDEGREEDAYS_I18N_KEY = 'target_degree_days'

    def series_names;  [TARGETDEGREEDAYS]; end

    def day_breakdown(d1, d2)
      { TARGETDEGREEDAYS => meter.target_degreedays_average_in_date_range(d1, d2) }
    end
  end

  #=====================================================================================================
  class Cusum < ModelManagerBase
    CUSUM = 'CUSUM'
    CUSUM_I18N_KEY = 'cusum'

    def series_names;  [CUSUM]; end

    def day_breakdown(d1, d2)
      scale = scaling_factor_for_model_derived_gas_data(kwh_cost_or_co2)
      model_kwh = heating_model.predicted_kwh_daterange(d1, d2, school.temperatures)
      actual_kwh = amr_data_date_range(meter, d1, d2, :kwh)
      { CUSUM => (model_kwh - actual_kwh) * scale }
    end
  end

  #=====================================================================================================
  class Baseload < ManagerBase
    BASELOAD = 'BASELOAD'
    BASELOAD_I18N_KEY = 'baseload'

    def series_names;  [BASELOAD]; end

    def day_breakdown(date1, date2)
      { BASELOAD => ::Baseload::BaseloadAnalysis.new(meter).average_baseload_kw(date1, date2) }
    end
  end

  #=====================================================================================================
  class PeakKw < ManagerBase
    PEAK_KW = 'Peak (kW)'
    PEAK_KW_I18N_KEY = 'peak_kw'

    def series_names;  [PEAK_KW]; end

    def day_breakdown(d1, d2)
      { PEAK_KW => meter.amr_data.peak_kw_kwh_date_range(d1, d2) }
    end
  end

  #=====================================================================================================
  class HeatingDayType < ModelManagerBase
    SCHOOLDAYHEATING  = 'Heating On School Days'
    HOLIDAYHEATING    = 'Heating On Holidays'
    WEEKENDHEATING    = 'Heating On Weekends'
    SCHOOLDAYHOTWATER = 'Hot water/kitchen only On School Days'
    HOLIDAYHOTWATER   = 'Hot water/kitchen only On Holidays'
    WEEKENDHOTWATER   = 'Hot water/kitchen only On Weekends'
    BOILEROFF         = 'Boiler Off'.freeze
    HEATINGDAYTYPESERIESNAMES = [SCHOOLDAYHEATING, HOLIDAYHEATING, WEEKENDHEATING, SCHOOLDAYHOTWATER, HOLIDAYHOTWATER, WEEKENDHOTWATER, BOILEROFF]

    SCHOOLDAYHEATING_I18N_KEY  = 'school_day_heating'
    HOLIDAYHEATING_I18N_KEY    = 'holiday_heating'
    WEEKENDHEATING_I18N_KEY    = 'weekend_heating'
    SCHOOLDAYHOTWATER_I18N_KEY = 'school_day_hot_water_kitchen'
    HOLIDAYHOTWATER_I18N_KEY   = 'holiday_hot_water_kitchen'
    WEEKENDHOTWATER_I18N_KEY   = 'weekend_hot_water_kitchen'
    BOILEROFF_I18N_KEY         = 'boiler_off'

    def series_names;  HEATINGDAYTYPESERIESNAMES; end

    def day_breakdown(d1, d2)
      # meter = (!electricity_meter.nil? && electricity_meter.storage_heater?) ? electricity_meter : heat_meter
      heating_data = default_breakdown
      (d1..d2).each do |date|
        type = convert_model_name_to_heating_daytype(date)
        one_day_value = amr_data_one_day(meter, date, kwh_cost_or_co2)
        # this is a fudge, to avoid restructuring of aggregation/series data manager interface
        # based back to allow count to work for adding 'XXX days' to legend
        # the modelling of 'BOILEROFF' allows days with small kWh, assuming its meter noise
        one_day_value = Float::MIN if one_day_value == 0.0 && type == BOILEROFF
        heating_data[type] += one_day_value
      end
      heating_data
    end

    def convert_model_name_to_heating_daytype(date)
      # use daytype logic here, rather than switching on model types
      # which have also had daytype logic applied to them
      # small risk of inconsistancy, but reduces dependancy between
      # this code and the regression models
      return BOILEROFF if heating_model.boiler_off?(date)

      heating_on = heating_model.heating_on?(date)
      if school.holidays.holiday?(date)
        heating_on ? HOLIDAYHEATING : HOLIDAYHOTWATER
      elsif DateTimeHelper.weekend?(date)
        heating_on ? WEEKENDHEATING : WEEKENDHOTWATER
      else
        heating_on ? SCHOOLDAYHEATING : SCHOOLDAYHOTWATER
      end
    end
  end
end
