class ManagementSummaryTable < ContentBase
  # rubocop:disable Metrics/ClassLength
  NO_RECENT_DATA_MESSAGE = 'no recent data'
  NOT_ENOUGH_DATA_MESSAGE = 'not enough data'
  NOTAVAILABLE = 'n/a'
  MAX_DAYS_OUT_OF_DATE_FOR_1_YEAR_COMPARISON = 3 * 30 # used elsewhere in alerts code base TODO(PH, 1Dec2021) rationalise with calculaiton config below at some point
  INCREASED_MESSAGE = 'increased'
  DECREASED_MESSAGE = 'decreased'
  NON_NUMERIC_DATA = [
    NO_RECENT_DATA_MESSAGE,
    NOT_ENOUGH_DATA_MESSAGE,
    NOTAVAILABLE,
    INCREASED_MESSAGE,
    DECREASED_MESSAGE
  ]
  attr_reader :scalar
  attr_reader :summary_data
  attr_reader :calculation_worked

  def initialize(school)
    super(school)
    @scalar = CalculateAggregateValues.new(@school)
    @rating = nil
  end

  def valid_alert?
    true
  end

  def rating
    5.0
  end

  def self.template_variables
    { 'Head teacher\'s energy summary' => TEMPLATE_VARIABLES}
  end

  TEMPLATE_VARIABLES = {
    summary_data: {
      description: 'Summary of annual per fuel consumption, annual change, 1 week change, saving to exemplar',
      units: :hash,
      # just returns a table like hash, doesn't fit within the existing alerts tabular framework
      # data returned is relatively unformatted i.e. raw apart from some strings e.g. '-n/a' to indicate no saving
    }
  }

  def analyse(asof_date = Date.today)
    asof_date ||= Date.today
    @asof_date = asof_date
    calculate
  end

  def check_relevance
    true
  end

  def enough_data
    :enough
  end

  def relevance
    :relevant
  end

  private

  def calculate
    @summary_data = extract_front_end_data(calculate_data)
    @calculation_worked = true
  end

  # Month produces a list of calendar months
  # But we might only have partial data for that month
  # So if we only want to show full months, e.g. if school has
  # 6 weeks of data spanning Sept and Oct, then we need to
  # check against the minimum date and then not calculate

  def calculation_configuration
    {
      year: {
        period0: { year: 0 },
        period1: { year: -1 },
        versus_exemplar: true,
        recent_limit: 2 * 365
      },
      last_month: {
        period0: { month: -1 }, # last calendar month
        period1: { month: -13 }, # same month last year
        versus_exemplar: false,
        recent_limit: 5 * 7 # over a month
      },
      workweek: {
        period0: { workweek: 0 },
        period1: { workweek: -1 },
        versus_exemplar: false,
        recent_limit: 2 * 7
      }
    }
  end

  def calculate_data
    @school.fuel_types(false).map do |fuel_type|
      [
        fuel_type,
        calculate_data_for_fuel(fuel_type)
      ]
    end.to_h
  end

  def calculate_data_for_fuel(fuel_type)
    res = calculation_configuration.map do |name, config|
      [
        name,
        calculate_period(fuel_type, config)
      ]
    end.to_h

    meter = @school.aggregate_meter(fuel_type)
    res[:start_date] = meter.amr_data.start_date
    res[:end_date]   = meter.amr_data.end_date

    res
  end

  def calculate_period(fuel_type, config)
    res = compare_two_periods(fuel_type, config[:period0], config[:period1], config[:recent_limit])
    res[:savings_£] = difference_to_exemplar_£(res[:£], fuel_type) if config[:versus_exemplar]
    res
  end

  # Overrides base class
  protected def format(unit, value, format, in_table, level)
    return value if NON_NUMERIC_DATA.include?(value)  # bypass front end auto cell table formatting
    FormatUnit.format(unit, value, format, true, in_table, level)
  end

  def difference_to_exemplar_£(actual_£, fuel_type)
    return nil if actual_£.nil?
    examplar = BenchmarkMetrics.exemplar_£(@school, fuel_type, nil, nil)
    return nil if examplar.nan?
    [actual_£ - examplar, 0.0].max
  end

  def compare_two_periods(fuel_type, period1, period2, max_days_out_of_date)
    current_period_kwh  = checked_get_aggregate(period1, fuel_type, :kwh)
    previous_period_kwh = checked_get_aggregate(period2, fuel_type, :kwh)
    current_period_co2 = if @school.solar_pv_panels? && fuel_type == :electricity
                          electricity_co2_with_solar_offset(period1)
                         else
                          checked_get_aggregate(period1, fuel_type, :co2)
                         end
    current_period      = checked_get_aggregate(period1, fuel_type, :£)
    previous_period     = checked_get_aggregate(period2, fuel_type, :£)
    out_of_date         = comparison_out_of_date(period1, fuel_type, max_days_out_of_date)

    valid               = current_period_kwh.nil? || previous_period_kwh.nil? || out_of_date
    percent_change      = valid ? nil : percent_change_with_zero(current_period_kwh, previous_period_kwh)

    {
      kwh:            current_period_kwh,
      co2:            current_period_co2,
      £:              current_period,
      percent_change: out_of_date ? NO_RECENT_DATA_MESSAGE : percent_change
     }
  end

  def percent_change_with_zero(current_period, previous_period)
    if current_period == previous_period
      0.0
    elsif previous_period == 0.0
      INCREASED_MESSAGE
    elsif current_period == 0.0
      DECREASED_MESSAGE
    else
      (current_period - previous_period)/previous_period
    end
  end

  def checked_get_aggregate(period, fuel_type, data_type, max_days_out_of_date = nil)
    begin
      scalar.aggregate_value(period, fuel_type, data_type, nil, max_days_out_of_date)
    rescue EnergySparksNotEnoughDataException => _e
      nil
    end
  end

  def electricity_co2_with_solar_offset(period = { year: 0})
    scalar = CalculateAggregateValues.new(@school)
    consumption   = checked_get_aggregate(period, :electricity, :co2)
    #
    # Note: we might end up with nil values for pv_production here if there's less than a years worth of generation
    # data. Can happen if the meter with the solar panels is lagging, but there is an "ignore end date" attribute set
    # such that the aggregate meter has a wider date range. In this case we have more limited generation data
    # than we do for consumption data.
    #
    # Really this code needs a rework so that it uses a similar approach to the solar pv/profit loss. But for now
    # if we're calculating the annual value, use :up_to_a_year as its more forgiving of limited data, but will use
    # full year if available
    period = { up_to_a_year: 0 } if period == { year: 0 }
    pv_production = checked_get_aggregate(period, :solar_pv, :co2)
    # NB solar pv panel putput CO2 is -tve, sign reversed in AMRData, so we add the values
    net_co2 = consumption.nil? || pv_production.nil? ? nil : (consumption + pv_production)
  end

  def comparison_out_of_date(period1, fuel_type, max_days_out_of_date)
    begin
      checked_get_aggregate(period1, fuel_type, :kwh, max_days_out_of_date)
      false
    rescue EnergySparksMeterDataTooOutOfDate => _e
      true
    end
  end

  # Reworks the calculation to:
  #
  # convert start/end dates to is08601
  # check for missing data and add :available_from
  # add :recent flag
  # add saving, which might be "n/a"
  # add percent change, but including "n/a" and "none"
  def extract_front_end_data(calc)
    front_end = {}

    calc.each do |fuel_type, fuel_type_data|
      front_end[fuel_type] = {}

      front_end[fuel_type][:start_date] = fuel_type_data[:start_date].iso8601
      front_end[fuel_type][:end_date]   = fuel_type_data[:end_date].iso8601

      fuel_type_data.each do |period, period_data|
        next if %i[start_date end_date].include?(period)

        front_end[fuel_type][period] = {}

        if period_data[:kwh].nil?
          front_end[fuel_type][period][:available_from] = date_available_from(period, fuel_type_data)
        else
          is_recent = @asof_date - fuel_type_data[:end_date] < calculation_configuration[period][:recent_limit]
          front_end[fuel_type][period][:recent] = is_recent
          front_end[fuel_type][period][:kwh]            = period_data[:kwh]
          front_end[fuel_type][period][:co2]            = period_data[:co2]
          front_end[fuel_type][period][:£]              = period_data[:£]
          front_end[fuel_type][period][:savings_£]      = positive_saving(period_data[:savings_£])
          front_end[fuel_type][period][:percent_change] = percent_change(period_data[:percent_change])
        end
      end
    end

    front_end
  end

  def date_available_from(period, fuel_type_data)
    if period == :workweek
      date = fuel_type_data[:start_date] + ((7 - fuel_type_data[:start_date].wday) % 7) + 7
      date.iso8601
    elsif period == :last_month
      # Start date might be partial data for previous month
      # So next full month available end of this month
      month_end = [fuel_type_data[:start_date].end_of_month, fuel_type_data[:end_date].end_of_month].max
      (month_end + 1.day).iso8601
    elsif period == :year
      (fuel_type_data[:start_date] + 365.days).iso8601
    else
      'Date available from: internal error'
    end
  end

  def positive_saving(val)
    if val.nil?
      NOTAVAILABLE
    elsif val <= 0.0
      'none'
    else
      val
    end
  end

  def percent_change(percent)
    percent.nil? || !percent.is_a?(Float) ? NOTAVAILABLE : percent
  end
end
