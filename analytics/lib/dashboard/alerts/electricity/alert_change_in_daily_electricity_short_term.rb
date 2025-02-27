#======================== Change in Daily Electricity Consumption =============
require_relative 'alert_electricity_only_base.rb'

#NOTE: This is not registered in the application database, so not actually in direct use?
#REMOVE?
class AlertChangeInDailyElectricityShortTerm < AlertElectricityOnlyBase
  MAXDAILYCHANGE = 1.05

  attr_reader :last_weeks_consumption_kwh, :week_befores_consumption_kwh
  attr_reader :last_weeks_consumption_£, :week_befores_consumption_£
  attr_reader :last_weeks_consumption_co2, :week_befores_consumption_co2
  attr_reader :signifcant_increase_in_electricity_consumption
  attr_reader :beginning_of_week, :beginning_of_last_week
  attr_reader :percent_change_in_consumption, :tariff_has_changed_between_periods_text

  def initialize(school)
    super(school, :changeinelectricityconsumption)
  end

  protected def max_days_out_of_date_while_still_relevant
    21
  end

  def self.template_variables
    specific = {'Change in electricity short term' => TEMPLATE_VARIABLES}
    specific.merge(self.superclass.template_variables)
  end

  TEMPLATE_VARIABLES = {
    last_weeks_consumption_kwh: {
      description: 'Last weeks electricity consumption on school days - kwh',
      units:  {kwh: :electricity}
    },
    week_befores_consumption_kwh: {
      description: 'The week befores electricity consumption on school days - kwh',
      units:  {kwh: :electricity}
    },
    last_weeks_consumption_£: {
      description: 'Last weeks electricity consumption on school days - £',
      units:  :£
    },
    week_befores_consumption_£: {
      description: 'The week befores electricity consumption on school days - £',
      units:  :£,
    },
    last_weeks_consumption_co2: {
      description: 'Last weeks electricity consumption on school days - co2',
      units:  :co2
    },
    week_befores_consumption_co2: {
      description: 'The week befores electricity consumption on school days - co2',
      units:  :co2,
    },
    signifcant_increase_in_electricity_consumption: {
      description: 'More than 5% increase in weekly electricity consumption in last 2 weeks',
      units:  TrueClass
    },
    percent_change_in_consumption: {
      description: 'Percent change in electricity consumption between last 2 weeks',
      units:  :percent
    },
    beginning_of_week: {
      description: 'Date of beginning of most recent assessment week',
      units: :date
    },
    beginning_of_last_week: {
      description: 'Date of beginning of previous assessment week',
      units: :date
    },
    week_on_week_electricity_daily_electricity_comparison_chart: {
      description: 'Week on week daily electricity comparison chart column chart',
      units: :chart
    },
    last_5_weeks_intraday_school_day_chart: {
      description: 'Average kW intraday for last 5 weeks line chart',
      units: :chart
    },
    last_7_days_intraday_chart: {
      description: 'Last 7 days intraday chart line chart',
      units: :chart
    },
    tariff_has_changed_between_periods_text: {
      description: 'The £ values use the latest tariff, so if the change is during a change in tariff it may not reflect what the user is expecting, so this provides from caveat test or blank if there is no change',
      units:  String
    }
  }.freeze

  def week_on_week_electricity_daily_electricity_comparison_chart
    :alert_week_on_week_electricity_daily_electricity_comparison_chart
  end

  def last_5_weeks_intraday_school_day_chart
    :alert_intraday_line_school_days_last5weeks
  end

  def last_7_days_intraday_chart
    :alert_intraday_line_school_last7days
  end

  def timescale
    'week (school days only)'
  end

  def enough_data
    days_amr_data > 3 * 7 ? :enough : :not_enough
  end

  private def calculate(asof_date)
    # super(asof_date)
    days_in_week = 5
    average_school_days_in_year = 195.0

    last_5_school_day_dates     = last_n_school_days(asof_date, days_in_week)
    previous_5_school_day_dates = last_n_school_days(last_5_school_day_dates[0] - 1, days_in_week)

    @beginning_of_week      = last_5_school_day_dates[0]
    @beginning_of_last_week = previous_5_school_day_dates[0]

    p1 = Range.new(last_5_school_day_dates.first, last_5_school_day_dates.last)
    p2 = Range.new(previous_5_school_day_dates.first, previous_5_school_day_dates.last)

    @tariff_has_changed_between_periods_text = calculate_tariff_has_changed_between_periods_text(p1, p2)

    @last_weeks_consumption_kwh   = schoolday_energy_usage_dates(last_5_school_day_dates, :kwh)
    @week_befores_consumption_kwh = schoolday_energy_usage_dates(previous_5_school_day_dates, :kwh)

    @last_weeks_consumption_£   = schoolday_energy_usage_dates(last_5_school_day_dates, :£current)
    @week_befores_consumption_£ = schoolday_energy_usage_dates(previous_5_school_day_dates, :£current)

    @last_weeks_consumption_co2   = schoolday_energy_usage_dates(last_5_school_day_dates, :co2)
    @week_befores_consumption_co2 = schoolday_energy_usage_dates(previous_5_school_day_dates, :co2)

    @signifcant_increase_in_electricity_consumption = @last_weeks_consumption_kwh > @week_befores_consumption_kwh * MAXDAILYCHANGE

    @percent_change_in_consumption = ((@last_weeks_consumption_kwh - @week_befores_consumption_kwh) / @week_befores_consumption_kwh)

    saving_kwh  = average_school_days_in_year * (@last_weeks_consumption_kwh - @week_befores_consumption_kwh) / days_in_week
    saving_£    = average_school_days_in_year * (@last_weeks_consumption_£   - @week_befores_consumption_£)   / days_in_week
    saving_co2  = average_school_days_in_year * (@last_weeks_consumption_co2 - @week_befores_consumption_co2) / days_in_week

    assign_commmon_saving_variables(one_year_saving_kwh: saving_kwh, one_year_saving_£: saving_£, one_year_saving_co2: saving_co2)

    @rating = calculate_rating_from_range(-0.05, 0.15, @percent_change_in_consumption)
    @status = @signifcant_increase_in_electricity_consumption ? :bad : :good
    @term = :shortterm
  end
  alias_method :analyse_private, :calculate

  private def schoolday_energy_usage_dates(dates, data_type)
    dates.map do |date|
      @school.aggregated_electricity_meters.amr_data.one_day_kwh(date, data_type)
    end.sum
  end
end
