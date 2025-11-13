#======================== Heating coming on too early in morning ==============
require_relative '../../gas/alert_gas_model_base.rb'

class AlertSummerHolidayRefrigerationAnalysis < AlertElectricityOnlyBase
  MINIMUM_SUMMER_DROP_KW = 0.2
  RATING_BASED_ON_YEARS_DATA = 3
  SIGNIFICANT_£_DROP = 200
  INEFFICIENT_APPLIANCES_KW = 1.0 # zero rating range

  attr_reader :summer_holiday_analysis_table
  attr_reader :holiday_reduction_£, :annualised_reduction_£, :reduction_kw
  attr_reader :reduction_rating, :turn_off_rating

  def initialize(school)
    super(school, :heatingcomingontooearly)
    @fridge_analysis = RefrigerationAnalysis.new(@school) unless aggregate_meter.nil?
  end

  def self.template_variables
    specific = {'Summer holiday fridge freezer analysis' => TEMPLATE_VARIABLES}
    specific.merge(self.superclass.template_variables)
  end

  TABLE_COLUMN_HEADERS = [
    'Holiday',
    'Baseload outside holiday (kW)',
    'Baseload in summer holidays (kW)',
    'Change in baseload (kW)',
    'Annualised value of reduction',
    'Significant change?'
  ]

  TABLE_COLUMN_UNITS = [
    String,
    :kw,
    :kw,
    :kw,
    :£,
    String
  ]

  TABLE_HASH_KEYS = %i[
    holiday_name
    weekend_baseload_kw
    holiday_baseload_kw
    change_in_baseload_kw
    annualised_saving_£
    signifcant_change
  ]

  TEMPLATE_VARIABLES = {
    summer_holiday_analysis_table: {
      description:  'Change in baseload during summer holidays',
      units:        :table,
      header:       TABLE_COLUMN_HEADERS,
      column_types: TABLE_COLUMN_UNITS
    },
    annualised_reduction_£: {
      description: 'Annualised value of reduction over holiday',
      units:  :£,
      benchmark_code: 'ann£'
    },
    holiday_reduction_£: {
      description: 'Implied reduction in baseload over period of holiday',
      units:  :£,
      benchmark_code: 'hol£'
    },
    reduction_kw: {
      description: 'Average reduction over summer in recent years when there has been a reduction in kW',
      units:  :kw,
      benchmark_code: 'kwrd'
    },
    reduction_rating: {
      description: 'rating of size of reduction, the smaller the rating potentially the more inefficient switched off appliances are',
      units:  :float,
      benchmark_code: 'rrat'
    },
    turn_off_rating: {
      description: 'rating based on number of recent summers appliances has been turned off 10.0 = all, 0.0 = none',
      units:  :float,
      benchmark_code: 'trat'
    },
    summary: {
      description: 'Annual benefit of reducing refrigeration costs',
      units: String
    }
  }.freeze

  def timescale
    I18n.t("#{i18n_prefix}.timescale")
  end

  def summer_holiday_analysis_table_html
    AlertRenderTable.new(TABLE_COLUMN_HEADERS, holiday_data_table(:html)).render
  end

  def analysis_periods
    @summer_holiday_periods ||= @fridge_analysis.periods_around_summer_holidays
  end

  def enough_data
    analysis_periods.empty? ? :not_enough : :enough
  end

  def calculate(asof_date)
    raise EnergySparksNotEnoughDataException, 'meter readings prior to last summer holiday required' if enough_data == :not_enough
    @summer_holiday_analysis_table = holiday_data_table

    ratings_based_on_last_n_years_data

    @rating = [@turn_off_rating, @reduction_rating].min

    @term = :longterm
  end
  alias_method :analyse_private, :calculate

  private

  def summary
    if @annualised_reduction_£ > 0
      I18n.t("#{i18n_prefix}.summary.high", saving: FormatUnit.format(:£, @annualised_reduction_£, :text))
    else
      I18n.t("#{i18n_prefix}.summary.ok")
    end
  end

  # difficulty to assign a range, if nothing changes then appliances
  # have not been turned off, if there are changes then it suggests
  # an inefficient appliance
  def ratings_based_on_last_n_years_data(years = RATING_BASED_ON_YEARS_DATA)
    years_data = summer_holiday_data[0...RATING_BASED_ON_YEARS_DATA]

    years_no_drop = years_without_significant_drop(years_data)
    @turn_off_rating = calculate_rating_from_range(0, RATING_BASED_ON_YEARS_DATA, years_no_drop.length)

    average_drop_value_£(years_data)
    @reduction_rating = calculate_rating_from_range(0, INEFFICIENT_APPLIANCES_KW, @reduction_kw)
  end

  def average_drop_value_£(years_data)
    data = years_with_significant_drop(years_data)
    @annualised_reduction_£  = average_hash_by_key(years_data,  :annualised_saving_£)
    @holiday_reduction_£     = average_hash_by_key(years_data,  :holiday_saving_£)
    @reduction_kw = average_hash_by_key(years_data, :change_in_baseload_kw)
  end

  def average_hash_by_key(arr, k)
    values = arr.map { |row| row[k] }
    values.sum / values.length
  end

  def years_without_significant_drop(years_data)
    years_data.select{ |year| year[:annualised_saving_£] < SIGNIFICANT_£_DROP }
  end

  def years_with_significant_drop(years_data)
    years_data.select{ |year| year[:annualised_saving_£] > SIGNIFICANT_£_DROP }
  end

  def holiday_data_table(medium = :raw)
    format_array_of_hashes_into_table(summer_holiday_data, TABLE_HASH_KEYS, TABLE_COLUMN_UNITS, medium)
  end

  def format_array_of_hashes_into_table(rows, keys, units, medium)
    rows.map do |row|
      keys.each_with_index.map do |key, column_number|
        format_for_table(row[key], units[column_number], medium)
      end
    end
  end

  def format_for_table(value, unit, medium)
    return value if medium == :raw || unit == String
    FormatUnit.format(unit, value, medium, false, true)
  end

  def summer_holiday_data
    @analysis_results ||= analysis_periods.map do |period_around_summer_holiday|
      @fridge_analysis.attempt_to_detect_refrigeration_being_turned_off_over_summer_holidays(period_around_summer_holiday, -MINIMUM_SUMMER_DROP_KW)
    end
  end

  def summer_holidays_with_drop
    summer_holiday_data.select{ |result| result[:change_in_baseload_kw] < -MINIMUM_SUMMER_DROP_KW }
  end
end
