require_relative './../common/alert_analysis_base.rb'
require_relative '../../utilities/energy_sparks_exceptions.rb'
# General base class for 6 alerts:
# - School week comparison: gas + electric
# - Previous holiday week comparison: gas + electric
# - Same holiday week last year comparison: gas + electric
# Generally try to recalculate periods everytime, just in case asof_date is varied in testing process
## school week, previous holiday, last year holiday comparison
#
# Relevance and enough data:
# - the alert is relevant only up to 3 weeks after the current period e.g. become irrelevant 3 weeks after a holiday
# - or for school weeks 3 weeks into a holiday
# - enough data - need enough meter data for both periods, but this can be less (6 days) than the whole period
# - so that the alert can for example signal the heating is on, if running in the middle of a holiday
# - for gas data, its also subject to enough model data for the model calculation to run
# Example as of dates for testing:
#   Whiteways: 4 Oct 2015: start of electricity, 6 Apr 2014 start of gas
#   Date.new(2015, 10, 6): all gas, but only school week relevant, no electricity
#   Date.new(2014, 7, 5): no electricity, no gas because of shortage of model data
#   Date.new(2014, 12, 1): no electricity, but should be enough model data to do school week, previous holiday, but not previous year holiday
#   Date.new(2018, 1, 1): all should be relevant
#   Date.new(2019, 3, 30): holiday alerts not relevant because towards end of term
#   Date.new(2019, 4, 3): holiday alerts not relvant because not far enough into holiday
#   Date.new(2019, 4, 10): all alerts should be relevant as far enough into holiday for enough data
#   Date.new(2019, 4, 24): all alerts should be relevant as within 3 weeks of end of holiday

class AlertPeriodComparisonBase < AlertAnalysisBase
  DAYS_ALERT_RELEVANT_AFTER_CURRENT_PERIOD = 3 * 7 # alert relevant for up to 3 weeks after period (holiday)
  # for the purposes to a 'relevant' alert we need a minimum of 6 days
  # period data, this ensures at least 1 weekend day is present for
  # the averaging process
  MINIMUM_WEEKDAYS_DATA_FOR_RELEVANT_PERIOD = 4
  MINIMUM_DIFFERENCE_FOR_NON_10_RATING_£ = 10.0
  attr_reader :difference_kwh, :difference_£, :difference_co2, :difference_percent, :abs_difference_percent
  attr_reader :abs_difference_kwh, :abs_difference_£, :abs_difference_co2
  attr_reader :current_period_kwh, :current_period_£, :current_period_co2, :current_period_start_date, :current_period_end_date
  attr_reader :previous_period_kwh, :previous_period_£, :previous_period_co2, :previous_period_start_date, :previous_period_end_date
  attr_reader :days_in_current_period, :days_in_previous_period
  attr_reader :current_period_average_kwh, :previous_period_average_kwh
  attr_reader :current_holiday_temperatures, :current_holiday_average_temperature
  attr_reader :previous_holiday_temperatures, :previous_holiday_average_temperature
  attr_reader :current_period_kwhs, :previous_period_kwhs_unadjusted, :previous_period_average_kwh_unadjusted
  attr_reader :current_period_weekly_kwh, :current_period_weekly_£, :previous_period_weekly_kwh, :previous_period_weekly_£
  attr_reader :previous_period_kwh_unadjusted
  attr_reader :change_in_weekly_kwh, :change_in_weekly_£
  attr_reader :change_in_weekly_percent
  attr_reader :current_period_floor_area, :previous_period_floor_area, :floor_area_changed
  attr_reader :current_period_pupils, :previous_period_pupils, :pupils_changed
  attr_reader :truncated_current_period
  attr_reader :difference_£current, :abs_difference_£current, :current_period_£current, :previous_period_£current
  attr_reader :current_period_weekly_£current, :previous_period_weekly_£current, :change_in_weekly_£current
  attr_reader :current_period_£_per_kwh, :previous_period_£_per_kwh, :tariff_has_changed

  def self.dynamic_template_variables(fuel_type)
    vars = {
      difference_kwh:       { description: 'Difference in kwh between last 2 periods',      units:  { kwh: fuel_type }, benchmark_code: 'difk' },
      difference_£:         { description: 'Difference in £ between last 2 periods (using historic tariffs)',  units:  :£, benchmark_code: 'dif£'},
      difference_£current:  { description: 'Difference in £ between last 2 periods (using latest tariffs)',    units:  :£current, benchmark_code: 'dif€'},
      difference_co2:     { description: 'Difference in co2 kg between last 2 periods', units:  :co2, benchmark_code: 'difc' },
      abs_difference_kwh: { description: 'Difference in kwh between last 2 periods - absolute',    units:  { kwh: fuel_type } },
      abs_difference_£:        { description: 'Difference in £ between last 2 periods - absolute (using historic tariffs)', units:  :£},
      abs_difference_£current: { description: 'Difference in £ between last 2 periods - absolute (using latest tariffs)',   units:  :£current},
      abs_difference_co2: { description: 'Difference in co2 kg between last 2 periods - absolute', units:  :co2 },
      difference_percent: { description: 'Difference in % between last 2 periods',   units:  :percent, benchmark_code: 'difp'  },
      abs_difference_percent: { description: 'Difference in % between last 2 periods - absolute, positive number only',   units:  :percent },

      current_period_kwh:        { description: 'Current period kwh',                 units:  { kwh: fuel_type }, benchmark_code: 'cppk'},
      current_period_co2:        { description: 'Current period co2',                 units:  :co2, benchmark_code: 'cppc'},
      current_period_£:          { description: 'Current period £ (using historic tariffs)', units: :£,        benchmark_code: 'cpp£'},
      current_period_£current:   { description: 'Current period £ (using latest tariffs)',   units: :£current, benchmark_code: 'cpp€'},
      current_period_start_date: { description: 'Current period start date',          units:  :date  },
      current_period_end_date:   { description: 'Current period end date',            units:  :date  },
      days_in_current_period:    { description: 'No. of days in current period',      units: Integer },
      name_of_current_period:    { description: 'name of current period e.g. Easter', units: String, benchmark_code: 'cper' },
      current_period_type:       { description: 'Current period type e.g. easter',    units: String },

      previous_period_kwh:        { description: 'Previous period kwh (equivalent no. of days to current period)', units:  { kwh: fuel_type }, benchmark_code: 'pppk' },
      previous_period_kwh_unadjusted: { description: 'Previous period kwh (equivalent no. of days to current period, unadjusted for temperature)', units:  { kwh: fuel_type }, benchmark_code: 'pppu' },
      previous_period_£:          { description: 'Previous period £ (equivalent no. of days to current period) (using historic tariffs)',   units:  :£,         benchmark_code: 'ppp£'},
      previous_period_£current:   { description: 'Previous period £ (equivalent no. of days to current period) (using latest tariffs)',     units:  :£current,  benchmark_code: 'ppp€'},
      previous_period_co2:        { description: 'Current period co2',                                             units:  :co2, benchmark_code: 'pppc'},
      previous_period_start_date: { description: 'Previous period start date',      units:  :date,   },
      previous_period_end_date:   { description: 'Previous period end date',        units:  :date  },
      days_in_previous_period:    { description: 'No. of days in previous period',  units: Integer },
      name_of_previous_period:    { description: 'name of previous period',         units: String, benchmark_code: 'pper' },
      previous_period_type:       { description: 'Previous period type',            units: String },

      current_period_average_kwh:  { description: 'Current period average daily kwh', units:  { kwh: fuel_type } },
      previous_period_average_kwh: { description: 'Previous period average adjusted daily',    units:  { kwh: fuel_type } },

      truncated_current_period: { description: 'truncated period',                        units:  TrueClass, benchmark_code: 'cptr' },

      current_period_weekly_kwh:      { description: 'Current period normalised average weekly kwh',   units:  { kwh: fuel_type } },
      current_period_weekly_£:        { description: 'Current period normalised average weekly £ (using historic tariffs)', units:  :£  },
      current_period_weekly_£current: { description: 'Current period normalised average weekly £ (using current tariffs)',  units:  :£current  },
      previous_period_weekly_kwh: { description: 'Previous period normalised average weekly kwh',  units:  { kwh: fuel_type } },
      previous_period_weekly_£:        { description: 'Previous period normalised average weekly £ (using historic tariffs)',  units:  :£  },
      previous_period_weekly_£current: { description: 'Previous period normalised average weekly £ (using current tariffs)',   units:  :£current },
      change_in_weekly_kwh:       { description: 'Change in normalised average weekly kwh',        units:  { kwh: fuel_type } },
      change_in_weekly_£:         { description: 'Change in normalised average weekly £ (using historic tariffs)', units:  :£ },
      change_in_weekly_£current:  { description: 'Change in normalised average weekly £ (using current tariffs)',  units:  :£current },
      change_in_weekly_percent:   { description: 'Difference in weekly % between last 2 periods',  units:  :percent  },

      comparison_chart: { description: 'Relevant comparison chart', units: :chart },

      summary:  { description: 'Change in kwh spend, relative to previous period', units: String },
      prefix_1: { description: 'Change: up or down', units: String },
      prefix_2: { description: 'Change: increase or reduction', units: String },

      current_period_floor_area:  { description: 'Weighted average floor area current period',          units: :m2,       benchmark_code: 'cpfa' },
      previous_period_floor_area: { description: 'Weighted average floor area previous period',         units: :m2,       benchmark_code: 'ppfa' },
      floor_area_changed:         { description: 'Has floor area changed between periods?',             units: TrueClass, benchmark_code: 'fach' },
      current_period_pupils:      { description: 'Weighted average number of pupils in current period', units: :pupils,   benchmark_code: 'cpnp' },
      previous_period_pupils:     { description: 'Weighted average number of pupils in previous period',units: :pupils,   benchmark_code: 'ppnp' },
      pupils_changed:             { description: 'Has number of pupils changed between periods?',       units: TrueClass, benchmark_code: 'pnch' },

      current_period_£_per_kwh:  { description: 'Current period weighted tariff £ per kWh',  units: :£_per_kwh, benchmark_code: 'cp£k' },
      previous_period_£_per_kwh: { description: 'Previous period weighted tariff £ per kWh', units: :£_per_kwh, benchmark_code: 'pp£k' },
      tariff_has_changed:        { description: 'PTariff has changed between periods',       units: TrueClass,  benchmark_code: 'cppp' },
    }

    vars.merge(convert_equivalence_template_variables(equivalence_template_variables, { '_test' => vars  }))
  end

  protected def comparison_chart
    raise EnergySparksAbstractBaseClass, "Error: comparison_chart method not implemented for #{self.class.name}"
  end

  public def time_of_year_relevance
    @time_of_year_relevance ||= calculate_time_of_year_relevance(@asof_date)
  end

  def aggregate_meter
    fuel_type == :electricity ? @school.aggregated_electricity_meters : @school.aggregated_heat_meters
  end

  def timescale; 'Error- should be overridden' end

  # overridden in calculate
  def relevance
    !meter_readings_up_to_date_enough? ? :not_relevant : @relevance
  end

  def maximum_alert_date; aggregate_meter.amr_data.end_date end

  def calculate(asof_date)
    @asof_date ||= asof_date
    configure_models(asof_date)
    @truncated_current_period = false

    current_period, previous_period = last_two_periods(asof_date)

    # commented out 1Dec2019, in favour of alert prioritisation control
    # @relevance = time_relevance(asof_date) # during and up to 3 weeks after current period
    @relevance = (enough_periods_data(asof_date) ? :relevant : :never_relevant) if relevance == :relevant

    raise EnergySparksNotEnoughDataException, "Not enough data in current period: #{period_debug(current_period,  asof_date)}"  unless enough_days_data_for_period(current_period,  asof_date)
    raise EnergySparksNotEnoughDataException, "Not enough data in previous period: #{period_debug(previous_period,  asof_date)}" unless enough_days_data_for_period(previous_period, asof_date)

    calculate_floor_area_adjustments(current_period, previous_period)
    calculate_pupil_number_adjustments(current_period, previous_period)

    current_period_data             = meter_values_period(current_period)
    previous_period_data            = normalised_period_data(current_period, previous_period)

    @difference_kwh       = current_period_data[:kwh]       - previous_period_data[:kwh]
    @difference_£         = current_period_data[:£]         - previous_period_data[:£]
    @difference_£current  = current_period_data[:£current]  - previous_period_data[:£current]
    @difference_co2       = current_period_data[:co2]       - previous_period_data[:co2]

    @abs_difference_kwh       = @difference_kwh.magnitude
    @abs_difference_£         = @difference_£.magnitude
    @abs_difference_£current  = @difference_£current.magnitude
    @abs_difference_co2       = @difference_co2.magnitude
    @difference_percent       = calculate_percent_with_error(current_period_data[:kwh], previous_period_data[:kwh])

    @abs_difference_percent = @difference_percent.magnitude

    @current_period             = current_period
    @current_period_kwh         = current_period_data[:kwh]
    @current_period_£           = current_period_data[:£]
    @current_period_£current    = current_period_data[:£current]
    @current_period_co2         = current_period_data[:co2]
    @current_period_start_date  = current_period.start_date
    @current_period_end_date    = current_period.end_date
    @days_in_current_period     = current_period.days
    @current_period_average_kwh = @current_period_kwh / @days_in_current_period
    @current_period_£_per_kwh   = current_period_data[:£] / current_period_data[:kwh]

    @previous_period              = previous_period
    @previous_period_kwh          = previous_period_data[:kwh] * pupil_floor_area_adjustment
    @previous_period_£            = previous_period_data[:£] * pupil_floor_area_adjustment
    @previous_period_£current     = previous_period_data[:£current] * pupil_floor_area_adjustment
    @previous_period_co2          = previous_period_data[:co2]
    @previous_period_start_date   = previous_period.start_date
    @previous_period_end_date     = previous_period.end_date
    @days_in_previous_period      = previous_period.days
    @previous_period_£_per_kwh    = previous_period_data[:£] / previous_period_data[:kwh]

    @tariff_has_changed           = tariff_changed_significantly(@current_period_£_per_kwh, @previous_period_£_per_kwh)

    @previous_period_average_kwh  = @previous_period_kwh / @days_in_current_period

    previous_period_range = @previous_period_start_date..@previous_period_end_date
    (
      _previous_period_kwhs_unadjusted,
      _previous_period_average_kwh_unadjusted,
      @previous_period_kwh_unadjusted
    ) = formatted_kwh_period_unadjusted(previous_period_range)

    @current_period_weekly_kwh        = normalised_average_weekly_kwh(current_period,   :kwh,     false)
    @current_period_weekly_£          = normalised_average_weekly_kwh(current_period,   :£,       false)
    @current_period_weekly_£current   = normalised_average_weekly_kwh(current_period,   :£current,false)
    @previous_period_weekly_kwh       = normalised_average_weekly_kwh(previous_period,  :kwh,     temperature_adjust)
    @previous_period_weekly_£         = normalised_average_weekly_kwh(previous_period,  :£,       temperature_adjust)
    @previous_period_weekly_£current  = normalised_average_weekly_kwh(previous_period,  :£current,temperature_adjust)

    @change_in_weekly_kwh       = @current_period_weekly_kwh      - @previous_period_weekly_kwh
    @change_in_weekly_£         = @current_period_weekly_£        - @previous_period_weekly_£
    @change_in_weekly_£current  = @current_period_weekly_£current - @previous_period_weekly_£current
    @change_in_weekly_percent   = relative_change(@change_in_weekly_kwh, @previous_period_weekly_kwh)

    set_equivalence_variables(self.class.equivalence_template_variables)

    assign_commmon_saving_variables(
      one_year_saving_kwh: @difference_kwh,
      one_year_saving_£: @difference_£current,
      capital_cost: 0.0,
      one_year_saving_co2: @difference_co2)

    @rating = calculate_rating(@change_in_weekly_percent, @change_in_weekly_£, fuel_type)

    @term = :shortterm
  end
  alias_method :analyse_private, :calculate

  def self.equivalence_template_variables
    additional_vars = [
      {
        existing_variable:  :difference_kwh,
        convert_to:         :tree,
        convert_via:        :co2
      },
      {
        existing_variable:  :difference_co2,
        convert_to:         :ice_car,
        convert_via:        :kwh
      },
      {
        existing_variable:  :difference_co2,
        convert_to:         :smartphone,
        convert_via:        :kwh
      },
    ]
  end

  def prefix_1
    Adjective.adjective_for_change(@difference_percent, :up, :no_change, :down)
  end

  def prefix_2
    Adjective.adjective_for_change(@difference_percent, :increase, :unchanged, :reduction)
  end

  def name_of_current_period
    return nil if @current_period.nil?
    current_period_name(@current_period)
  end

  def current_period_type
    @current_period&.type
  end

  def name_of_previous_period
    return nil if @previous_period.nil?
    previous_period_name(@previous_period)
  end

  def previous_period_type
    @previous_period&.type
  end

  protected def current_period_name(period)
    period_name(period)
  end

  protected def previous_period_name(period)
    period_name(period)
  end

  protected def period_name(period)
    raise EnergySparksAbstractBaseClass, "Error: period_name not implemented for #{self.class.name}"
  end

  def enough_data
    return :not_enough if @not_enough_data_exception
    period1, period2 = last_two_periods(@asof_date)
    enough_days_data_for_period(period1, @asof_date) && enough_days_data_for_period(period2, @asof_date) ? :enough : :not_enough
  end

  protected

  def community_use
    nil
  end

  def minimum_days_for_period
    MINIMUM_WEEKDAYS_DATA_FOR_RELEVANT_PERIOD
  end

  def calculate_rating(percentage_difference, financial_difference_£, fuel_type)
    # The goal is to not show alerts when the cost saving is negligible.
    # Defined here as +/- £10. To do that we need to set the rating to nil (rather than 10)
    # as this will cause the application to ignore the results. A rating of 10 would
    # mean the application always aims to display the alert results.
    return nil if financial_difference_£.between?(-MINIMUM_DIFFERENCE_FOR_NON_10_RATING_£, MINIMUM_DIFFERENCE_FOR_NON_10_RATING_£)
    ten_rating_range_percent = fuel_type == :electricity ? 0.10 : 0.15 # more latitude for gas
    calculate_rating_from_range(-ten_rating_range_percent, ten_rating_range_percent, percentage_difference)
  end

  def last_two_periods(_asof_date)
    raise EnergySparksAbstractBaseClass, "Error: last_two_periods method not implemented for #{self.class.name}"
  end

  def fuel_type
    raise EnergySparksAbstractBaseClass, "Error: fuel_type method not implemented for #{self.class.name}"
  end

  def pupil_floor_area_adjustment
    if fuel_type == :gas
      @current_period_floor_area / @previous_period_floor_area
    else
      @current_period_pupils / @previous_period_pupils
    end
  end

  def configure_models(_asof_date)
    # do nothing in case of electricity
  end

  def temperature_adjustment(_date, _asof_date)
    1.0 # no adjustment for electricity, the default
  end

  def meter_values_period(current_period)
    %i[kwh £ £current co2].map do |datatype|
      [
        datatype,
        kwh_date_range(aggregate_meter, current_period.start_date, current_period.end_date, datatype)
      ]
    end.to_h
  end

  def normalised_period_data(current_period, previous_period)
    %i[kwh £ £current co2].map do |datatype|
      [
        datatype,
        normalise_previous_period_data_to_current_period(current_period, previous_period, datatype)
      ]
    end.to_h
  end

  # overridden by gas classes where this value is temperature compensated
  def kwh_date(aggregate_meter, date, data_type, adjusted)
    if adjusted
      temperature_adjust_kwh(aggregate_meter, date, data_type)
    else
      kwh_date_range(aggregate_meter, date, date, data_type)
    end
  end

  def temperature_adjust_kwh(aggregate_meter, date, data_type)
    raise EnergySparksAbstractBaseClass, "Error: temperature_adjust_kwh method not implemented for #{self.class.name}"
  end

  def calculate_time_of_year_relevance(asof_date)
    current_period, previous_period = last_two_periods(asof_date)
    # lower relevance just after a holiday, only prioritise when 2 whole weeks of
    # data post holiday, use 9 days as criteria to allow for non-whole weeks post holiday
    # further modified by fuel type in derived classes so gas higher priority in winter
    # and electricity in summer (CT request 15 Sep 2020)
    days_between_school_weeks = current_period.end_date - previous_period.end_date
    school_weeks_split_either_side_of_holiday = days_between_school_weeks > 9
    meter_data_days_out_of_date = asof_date - current_period.end_date
    meter_data_out_of_date = meter_data_days_out_of_date > 10 # agreed with CT 16Sep2020
    fuel_priority = fuel_time_of_year_priority(asof_date, current_period)
    time_relevance = (meter_data_out_of_date || school_weeks_split_either_side_of_holiday) ? 1.0 : fuel_priority
    time_relevance
  end

  def enough_days_data_for_period(period, asof_date)
    return false if period.nil?
    period_start = [aggregate_meter.amr_data.start_date,  period.start_date].max
    period_end   = [aggregate_meter.amr_data.end_date,    period.end_date, asof_date].min
    enough_days_data(period_days(period_start, period_end))
  end

  def period_days(period_start, period_end)
    SchoolDatePeriod.weekdays_inclusive(period_start, period_end)
  end

  private

  def period_debug(current_period,  asof_date)
    "#{current_period.nil? ? 'no current period' : current_period}, asof #{asof_date}"
  end

  def period_type
    'period'
  end

  def temperature_adjust; false end

  #£130 increase since last holiday, +160%
  def summary
    I18n.t("analytics.time_period_comparison",
      difference: FormatEnergyUnit.format(:kwh, @difference_kwh, :text),
      adjective: prefix_2,
      period_type: period_type,
      relative_percent: FormatEnergyUnit.format(:relative_percent, @difference_percent, :text))
  end

  def url_bookmark
    fuel_type == :electricity ? 'ElectricityChange' : 'GasChange'
  end

  def tariff_changed_significantly(t1_£_per_kwh, t2_£_per_kwh)
    return false if t1_£_per_kwh.nil? || t2_£_per_kwh.nil?

    return false if t1_£_per_kwh.nan? || t2_£_per_kwh.nan?

    t1_£_per_kwh.round(2) != t2_£_per_kwh.round(2)
  end

  def kwh_date_range(meter, start_date, end_date, data_type)
    super(aggregate_meter, start_date, end_date, data_type, community_use: community_use)
  end

  def formatted_kwh_period_unadjusted(period, data_type = :kwh)
    min_days_data_if_meter_start_date_in_holiday = 4
    values = kwhs_date_range(aggregate_meter, period.first, period.last, data_type, min_days_data_if_meter_start_date_in_holiday, community_use: community_use)
    formatted_values = "#{values.sum.round(0)} = #{values.map { |kwh| kwh.round(0) }.join('+')}"
    [formatted_values, values.sum / values.length, values.sum]
  end

  # adjust the previous periods electricity/gas usage to the number of days in the current period
  # by calculating the average weekday usage and average weekend usage, and multiplying
  # by the same number of days in the current holiday
  def normalise_previous_period_data_to_current_period(current_period, previous_period, data_type)
    current_weekday_dates = SchoolDatePeriod.matching_dates_in_period_to_day_of_week_list(current_period, (1..5).to_a)
    current_weekend_dates = SchoolDatePeriod.matching_dates_in_period_to_day_of_week_list(current_period, [0, 6])

    previous_average_weekdays = average_period_value(previous_period, (1..5).to_a, data_type, temperature_adjust)
    previous_average_weekends = average_period_value(previous_period, [0, 6], data_type, temperature_adjust)

    current_weekday_dates.length * previous_average_weekdays + current_weekend_dates.length * previous_average_weekends
  end

  def normalised_average_weekly_kwh(period, data_type, adjusted)
    weekday_average = average_period_value(period, (1..5).to_a, data_type, adjusted)
    weekend_average = average_period_value(period, [0, 6], data_type, adjusted)
    5.0 * weekday_average + 2.0 * weekend_average
  end

  def average_period_value(period, days_of_week, data_type, adjusted)
    dates = SchoolDatePeriod.matching_dates_in_period_to_day_of_week_list(period, days_of_week)
    return 0.0 if dates.empty?

    values = dates.map { |date| kwh_date(aggregate_meter, date, data_type, adjusted) }.compact
    values.sum / values.length
  end

  # relevant if asof date immediately at end of period or up to
  # 3 weeks after
  def time_relevance_deprecated(asof_date)
    current_period, _previous_period = last_two_periods(asof_date)
    return :never_relevant if current_period.nil?
    # relevant during period, subject to 'enough_data'
    return :relevant if enough_days_in_period(current_period, asof_date)
    days_from_end_of_period_to_asof_date = asof_date - current_period.end_date
    return days_from_end_of_period_to_asof_date.between?(0, DAYS_ALERT_RELEVANT_AFTER_CURRENT_PERIOD) ? :relevant : :never_relevant
  end

  def enough_periods_data(asof_date)
    current_period, previous_period = last_two_periods(asof_date)
    !current_period.nil? && !previous_period.nil?
  end

  def enough_days_in_period(period, asof_date)
    asof_date.between?(period.start_date, period.end_date) && enough_days_data(asof_date - period.start_date + 1)
  end

  def enough_days_data(days)
    days >= MINIMUM_WEEKDAYS_DATA_FOR_RELEVANT_PERIOD
  end

  def calculate_floor_area_adjustments(current_period, previous_period)
    @current_period_floor_area  = @school.floor_area(current_period.start_date, current_period.end_date)
    @previous_period_floor_area = @school.floor_area(previous_period.start_date, previous_period.end_date)
    @floor_area_changed = @current_period_floor_area != @previous_period_floor_area
  end

  def calculate_pupil_number_adjustments(current_period, previous_period)
    @current_period_pupils  = @school.number_of_pupils(current_period.start_date, current_period.end_date)
    @previous_period_pupils = @school.number_of_pupils(previous_period.start_date, previous_period.end_date)
    @pupils_changed = @current_period_pupils != @previous_period_pupils
  end

  def calculate_percent_with_error(current_value, previous_value)
    if current_value == 0.0 && previous_value == 0.0
      0.0 # avoid presenting NaN to user
    elsif previous_value == 0.0
      +Float::INFINITY
    elsif current_value == 0.0
      -Float::INFINITY
    else
      (current_value - previous_value) / previous_value
    end
  end
end

class AlertHolidayComparisonBase < AlertPeriodComparisonBase
  private def period_type
    'holiday'
  end

  def timescale
    I18n.t("#{i18n_prefix}.timescale")
  end

  protected def period_name(period)
    I18nHelper.holiday(period.type)
  end

  protected def truncate_period_to_available_meter_data(period)
    return nil if period.nil?
    return period if period.start_date >= aggregate_meter.amr_data.start_date && period.end_date <= aggregate_meter.amr_data.end_date
    start_date = [period.start_date, aggregate_meter.amr_data.start_date].max
    end_date = [period.end_date, aggregate_meter.amr_data.end_date].min
    if end_date >= start_date
      @truncated_current_period = true
      return SchoolDatePeriod.new(period.type, "#{period.title} truncated to available meter data", start_date, end_date)
    end
    nil
  end

  # relevant if asof date immediately at end of period or up to
  # 3 weeks after
  private def calculate_time_of_year_relevance(asof_date)
    current_period, _previous_period = last_two_periods(asof_date)
    return 0.0 if current_period.nil?
    # relevant during period, subject to 'enough_data'
    return 10.0 if enough_days_in_period(current_period, asof_date)
    days_from_end_of_period_to_asof_date = asof_date - current_period.end_date
    return 0.0 if days_from_end_of_period_to_asof_date > DAYS_ALERT_RELEVANT_AFTER_CURRENT_PERIOD
    percent_into_post_holiday_period = (days_from_end_of_period_to_asof_date - DAYS_ALERT_RELEVANT_AFTER_CURRENT_PERIOD) / DAYS_ALERT_RELEVANT_AFTER_CURRENT_PERIOD
    weight =  percent_into_post_holiday_period * 2.5
    10.0 - weight # scale down relevance of holiday comparison from 10.0 to 7.5 over relevance period (e.g. 3 weeks)
  end

end
