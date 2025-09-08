require_relative './alert_period_comparison_base.rb'
require_relative './alert_schoolweek_comparison_electricity.rb'
require_relative './alert_period_comparison_temperature_adjustment_mixin.rb'
require_relative './../gas/alert_model_cache_mixin.rb'
# Compares the last two SCHOOL weeks - i.e. when this school is occupied, i.e. skips holidays
# Unlike the other week/short term comparison alerts, it works completly off chart data
# and doesn't do the amr aggregation locally
#
# the data is adjjusted for temperature, so as per the chart definition the current week is unadjusted
# but the previous week is adjusted for the temperature differerence between the correspoding days of
# the two weeks, so for example if the current Monday was colder than the previous Monday, the
# previous Monday's data would be increased as determined by the model's temperature adjustment
#
class AlertSchoolWeekComparisonGas < AlertSchoolWeekComparisonElectricity
  include AlertModelCacheMixin
  include AlertPeriodComparisonTemperatureAdjustmentMixin
  attr_reader :current_week_kwhs, :previous_week_kwhs_unadjusted, :previous_week_kwhs_adjusted
  attr_reader :current_weeks_temperatures, :previous_weeks_temperatures
  attr_reader :current_week_kwh_total, :previous_week_kwh_unadjusted_total,  :previous_week_kwh_total
  attr_reader :current_weeks_average_temperature, :previous_weeks_average_temperature

  def initialize(school, type = :gaspreviousschoolweekcomparison)
    super(school, type)
  end

  def self.template_variables
    specific = { 'Adjusted gas school week specific (debugging)' => schoolweek_adjusted_gas_variables }
    specific['Change in between last 2 school weeks'] = dynamic_template_variables(:gas)
    specific.merge(superclass.template_variables)
  end

  protected def max_days_out_of_date_while_still_relevant
    21
  end

  def comparison_chart
    :alert_last_2_weeks_gas_comparison_temperature_compensated
  end

  def self.schoolweek_adjusted_gas_variables
    {
      current_week_kwhs:              { description: 'List of current school week kWh values', units:  String },
      previous_week_kwhs_unadjusted:  { description: 'List of previous school week kWh values (unadjusted)', units:  String  },
      previous_week_kwhs_adjusted:    { description: 'List of previous school week kWh values (adjusted)', units:  String  },
      current_week_kwh_total:             { description: 'Current week total kWh',                units:  :kwh  },
      previous_week_kwh_unadjusted_total: { description: 'Previous week total kWh (unadjusted)' , units:  :kwh, benchmark_code: 'najk'  },
      previous_week_kwh_total:            { description: 'Previous week total kWh (from chart, adjusted, maybe slightly different from previous_period_kwh which uses better underlying alert compensation )',    units:  :kwh, benchmark_code: 'ajkw'  },
    }
  end

  def fuel_type; :gas end

  private def period_type
    'school week'
  end

  def adjusted_temperature_comparison_chart
    :schoolweek_alert_2_week_comparison_for_internal_calculation_gas_adjusted
  end

  def unadjusted_temperature_comparison_chart
    :schoolweek_alert_2_week_comparison_for_internal_calculation_gas_unadjusted
  end

  def calculate(asof_date)
    @model_asof_date = asof_date
    # this needs to be called first
    calculate_temperature_adjusted_and_unadjusted_gas_from_chart_data(asof_date)
    super(asof_date)

    # this isn't ideal, the temperature compensation of the underlying
    # period comparison alert is subtely different from that of the
    # chart calculation, so use the chart's:
    # @previous_period_kwh = @previous_week_kwh_total
  end
  alias_method :analyse_private, :calculate

  protected def calculate_temperature_adjusted_and_unadjusted_gas_from_chart_data(asof_date)
    unadjusted_data = kwh_values_from_2_weekly_chart(unadjusted_temperature_comparison_chart, asof_date)
    adjusted_data = kwh_values_from_2_weekly_chart(adjusted_temperature_comparison_chart, asof_date)

    @current_week_kwhs              = format_a_weeks_kwh_values(unadjusted_data.values[1])
    @previous_week_kwhs_unadjusted  = format_a_weeks_kwh_values(unadjusted_data.values[0])
    @previous_week_kwhs_adjusted    = format_a_weeks_kwh_values(adjusted_data.values[0])

    @current_week_kwh_total             = unadjusted_data.values[1].sum
    @previous_week_kwh_unadjusted_total = unadjusted_data.values[0].sum
    @previous_week_kwh_total            = adjusted_data.values[0].sum

    @current_period  = SchoolDatePeriod.new(:schoolweek, 'Current school week',  unadjusted_data.keys[1].first, unadjusted_data.keys[1].last)
    @previous_period = SchoolDatePeriod.new(:schoolweek, 'Previous school week', unadjusted_data.keys[0].first, unadjusted_data.keys[0].last)
  end

  protected def last_two_periods(_asof_date)
    [@current_period, @previous_period]
  end

  private def format_a_weeks_kwh_values(values)
    values.map { |kwh| kwh.round(0) }.join(', ')
  end

  protected def kwh_values_from_2_weekly_chart(chart_name, asof_date)
    chart_manager = ChartManager.new(@school)
    results = chart_manager.run_standard_chart(chart_name, { asof_date: asof_date }, true)
    process_2_weekly_chart_results(results[:x_data])
  end

  protected def process_2_weekly_chart_results(chart_x_data)
    weeks_data = {} # [date_range] = [ 7 x daily kWh readings ]
    chart_x_data.each do |date_range_key, data|
      start_date, end_date = convert_x_axis_date_key_to_dates(date_range_key)
      weeks_data[start_date..end_date] = data
    end
    # force chronological order
    weeks_data.sort_by { |date_range, kwh_values| date_range.first }.to_h
  end

  private def convert_x_axis_date_key_to_dates(key)
    key.match(/Energy[:](.*)[-](.*)/).captures.map { |date_str| Date.parse(date_str) }
  end

  private def fuel_time_of_year_priority(asof_date, current_period)
    heating_on_in_period(asof_date, current_period) ? 7.5 : 2.5
  end

  private def heating_on_in_period(asof_date, period)
    @heating_model ||= model_cache(aggregate_meter, asof_date)
    school_days = (period.start_date..period.end_date).to_a.select{ |date| date.wday.between?(1,5) }
    heating_on_days = school_days.count{ |school_day| @heating_model.heating_on?(school_day) }
    heating_on_most_days = heating_on_days > (school_days.length / 2.0)
    heating_on_most_days
  end
end
