#======================== Weekend Gas Consumption =============================
# gas shouldn't be consumed at weekends, apart for from frost protection
require_relative 'alert_gas_model_base.rb'

class AlertWeekendGasConsumptionShortTerm < AlertGasModelBase
  MAX_COST = 5.0 # £5 limit
  FROST_PROTECTION_TEMPERATURE = 4
  NUM_WEEKEND_COMPARISON = 5 # don't change without chaging variable names

  attr_reader :last_week_end_kwh, :last_weekend_cost_£
  attr_reader :last_year_weekend_gas_kwh, :last_year_weekend_gas_£
  attr_reader :average_weekend_gas_kwh, :average_weekend_gas_£
  attr_reader :percent_increase_on_average_weekend, :projected_percent_of_annual
  attr_reader :last_5_weeks_average_weekend_kwh, :last_5_weeks_average_weekend_£, :percent_increase_on_last_5_weekends
  attr_reader :last_weekend_cost_co2, :last_year_weekend_gas_co2, :average_weekend_gas_co2, :last_5_weeks_average_weekend_co2
  attr_reader :last_weekend_cost_£current, :last_year_weekend_gas_£current
  attr_reader :average_weekend_gas_£current, :last_5_weeks_average_weekend_£current
  attr_reader :last_7_day_intraday_kwh_chart, :last_7_day_intraday_kw_chart, :last_7_day_intraday_£_chart, :last_7_day_intraday_£current_chart
  attr_reader :has_changed_during_period_text
  attr_reader :prior_weekend_dates_string
  attr_reader :weekend_dates_string
  attr_reader :frost_protection_hours
  attr_reader :last_week_end_kwh_including_frost, :last_week_end_£_including_frost
  attr_reader :last_week_end_£current_including_frost, :last_weekend_cost_co2_including_frost

  def initialize(school)
    super(school, :weekendgasconsumption)
  end

  protected def max_days_out_of_date_while_still_relevant
    21
  end

  def timescale
    I18n.t("#{i18n_prefix}.timescale")
  end

  def enough_data
    days_amr_data >= 7 ? :enough : :not_enough
  end

  def self.template_variables
    specific = {'Weekend gas consumption' => TEMPLATE_VARIABLES}
    specific.merge(self.superclass.template_variables)
  end

  TEMPLATE_VARIABLES = {
    last_week_end_kwh: {
      description: 'Gas consumption last weekend kWh (above frost)',
      units: { kwh: :gas }
    },
    last_week_end_kwh_including_frost: {
      description: 'Gas consumption last weekend kWh (including frost, excluded by the last_week_end_kwhvariable',
      units: :kwh
    },
    last_weekend_cost_£: {
      description: 'Gas consumption last weekend £ (above frost) (using historic gas tariffs)',
      units: :£
    },
    last_week_end_£_including_frost: {
      description: 'Gas consumption last weekend £(using historic gas tariffs)',
      units: :£
    },
    last_weekend_cost_£current: {
      description: 'Gas consumption last weekend £ (above frost) (using latest gas tariff)',
      units: :£current
    },
    last_week_end_£current_including_frost: {
      description: 'Gas consumption last weekend £  (using latest gas tariff)',
      units: :£current
    },
    last_weekend_cost_co2: {
      description: 'Gas consumption last weekend co2 (above frost)',
      units: :co2
    },
    last_weekend_cost_co2_including_frost: {
      description: 'Gas consumption last weekend co2',
      units: :co2
    },
    last_year_weekend_gas_kwh: {
      description: 'Gas consumption last year kWh (scaled up to a year if not enough data)',
      units: { kwh: :gas }
    },
    last_year_weekend_gas_£: {
      description: 'Gas consumption last year £ (scaled up to a year if not enough data) (using historic gas tariffs)',
      units: :£
    },
    last_year_weekend_gas_£current: {
      description: 'Gas consumption last year £ (scaled up to a year if not enough data) (using latest gas tariff)',
      units: :£current
    },
    last_year_weekend_gas_co2: {
      description: 'Gas consumption last year co2 (scaled up to a year if not enough data)',
      units: :co2
    },
    average_weekend_gas_kwh: {
      description: 'Average weekend gas consumption last year kWh (scaled up to a year if not enough data)',
      units: { kwh: :gas }
    },
    average_weekend_gas_£: {
      description: 'Average weekend gas consumption last year £ (scaled up to a year if not enough data) (using historic gas tariffs)',
      units: :£
    },
    average_weekend_gas_£current: {
      description: 'Average weekend gas consumption last year £ (scaled up to a year if not enough data) (using latest gas tariff)',
      units: :£current
    },
    average_weekend_gas_co2: {
      description: 'Average weekend gas consumption last year CO2 (scaled up to a year if not enough data)',
      units: :co2
    },
    percent_increase_on_average_weekend: {
      description: 'Percent increase on average weekend over last year',
      units: :percent
    },
    projected_percent_of_annual: {
      description: 'Last weekends (projected i.e. x 52) consumption as a percent of total annual gas consumption',
      units: :percent
    },
    last_5_weeks_average_weekend_kwh: {
      description: 'Average weekend gas consumption last 5 weeks kWh',
      units: { kwh: :gas }
    },
    last_5_weeks_average_weekend_£: {
      description: 'Average weekend gas consumption last 5 weeks £ (using historic gas tariffs)',
      units: :£
    },
    last_5_weeks_average_weekend_£current: {
      description: 'Average weekend gas consumption last 5 weeks £ (using latest gas tariff)',
      units: :£current
    },
    last_5_weeks_average_weekend_co2: {
      description: 'Average weekend gas consumption last 5 weeks co2',
      units: :co2
    },
    percent_increase_on_last_5_weekends: {
      description: 'Increase in last weekends gas consumption as a percentage of the last 5 weeks',
      units: :percent
    },
    has_changed_during_period_text: {
      description: 'Text says whether tariff changes in last 5 weeks of comparison period, or blank',
      units: String
    },
    weekend_dates_string: {
      description: 'Debug - list of weekend dates',
      units: String
    },
    prior_weekend_dates_string: {
      description: 'Debug - list of prior weekend dates',
      units: String
    },
    last_7_day_intraday_kwh_chart: {
      description: 'last 7 days gas consumption chart (intraday) - suggest zoom to user, kWh per half hour',
      units: :chart
    },
    last_7_day_intraday_kw_chart: {
      description: 'last 7 days gas consumption chart (intraday) - suggest zoom to user, kW per half hour',
      units: :chart
    },
    last_7_day_intraday_£_chart: {
      description: 'last 7 days gas consumption chart (intraday) - suggest zoom to user, £ per half hour (using historic gas tariffs)',
      units: :chart
    },
    last_7_day_intraday_£current_chart: {
      description: 'last 7 days gas consumption chart (intraday) - suggest zoom to user, £ per half hour (using latest gas tariff)',
      units: :chart
    },
    frost_protection_hours: {
      description: 'Number of hours of frost protection, excluded from value provided for weekend kWh usage',
      units: Float
    }
  }.freeze

  def last_7_day_intraday_kwh_chart
    :alert_weekend_last_week_gas_datetime_kwh
  end

  def last_7_day_intraday_kw_chart
    :alert_weekend_last_week_gas_datetime_kw
  end

  def last_7_day_intraday_£_chart
    :alert_weekend_last_week_gas_datetime_£
  end

  def last_7_day_intraday_£current_chart
    :alert_weekend_last_week_gas_datetime_£current
  end

  private def calculate(asof_date)
    calculate_model(asof_date)

    @weekend_dates = previous_weekend_dates(asof_date)
    @weekend_dates_string = @weekend_dates.map { |d| d.strftime('%d%b%Y') }.join(',')

    @last_week_end_kwh, @frost_protection_hours, @last_week_end_kwh_including_frost =
          kwh_usage_outside_frost_period(@weekend_dates, FROST_PROTECTION_TEMPERATURE, :kwh)
    @last_weekend_cost_£, _x, @last_week_end_£_including_frost =
          kwh_usage_outside_frost_period(@weekend_dates, FROST_PROTECTION_TEMPERATURE, :£)
    @last_weekend_cost_£current, _x, @last_week_end_£current_including_frost =
         kwh_usage_outside_frost_period(@weekend_dates, FROST_PROTECTION_TEMPERATURE, :£current)
    @last_weekend_cost_co2 = @last_week_end_kwh * EnergyEquivalences::UK_GAS_CO2_KG_KWH
    @last_weekend_cost_co2_including_frost = @last_week_end_kwh_including_frost * EnergyEquivalences::UK_GAS_CO2_KG_KWH

    @last_year_weekend_gas_kwh = weekend_gas_consumption_last_year(asof_date, :kwh)
    @last_year_weekend_gas_£ = weekend_gas_consumption_last_year(asof_date, :£)
    @last_year_weekend_gas_£current = weekend_gas_consumption_last_year(asof_date, :£current)
    @last_year_weekend_gas_co2 = @last_year_weekend_gas_kwh * EnergyEquivalences::UK_GAS_CO2_KG_KWH

    @average_weekend_gas_kwh      = @last_year_weekend_gas_kwh / 52.0
    @average_weekend_gas_£        = @last_year_weekend_gas_£ / 52.0
    @average_weekend_gas_£current = @last_year_weekend_gas_£current / 52.0
    @average_weekend_gas_co2      = @last_year_weekend_gas_co2 / 52.0

    @percent_increase_on_average_weekend = @average_weekend_gas_kwh == 0.0 ? 0.0 : (@last_week_end_kwh - @average_weekend_gas_kwh) / @average_weekend_gas_kwh
    @projected_percent_of_annual = @last_week_end_kwh * 52.0 / annual_kwh(aggregate_meter, asof_date)

    @last_5_weeks_average_weekend_kwh      = average_last_n_weekends_kwh(@weekend_dates, :kwh, NUM_WEEKEND_COMPARISON)
    @last_5_weeks_average_weekend_£        = average_last_n_weekends_kwh(@weekend_dates, :£,   NUM_WEEKEND_COMPARISON)
    @last_5_weeks_average_weekend_£current = average_last_n_weekends_kwh(@weekend_dates, :£current,   NUM_WEEKEND_COMPARISON)
    @last_5_weeks_average_weekend_co2 = @last_5_weeks_average_weekend_kwh * EnergyEquivalences::UK_GAS_CO2_KG_KWH
    @percent_increase_on_last_5_weekends = @last_5_weeks_average_weekend_kwh == 0.0 ? 0.0 : (@last_week_end_kwh - @last_5_weeks_average_weekend_kwh) / @last_5_weeks_average_weekend_kwh

    prior_dates = prior_weekend_dates(@weekend_dates, NUM_WEEKEND_COMPARISON)
    @prior_weekend_dates_string = prior_dates.sort.map { |d| d.strftime('%d%b') }.join(',') + prior_dates.max.strftime('%Y')

    @has_changed_during_period_text = calculate_tariff_has_changed_during_period_text(prior_dates.min, asof_date)

    increase_rating_on_year = calculate_rating_from_range(0.0, 0.20, @percent_increase_on_average_weekend)
    increase_rating_on_last_5_weeks = calculate_rating_from_range(0.0, 0.20, @percent_increase_on_last_5_weekends)
    of_annual_rating = calculate_rating_from_range(0.02, 0.12, @projected_percent_of_annual)
    combined_rating = increase_rating_on_year * of_annual_rating * increase_rating_on_last_5_weeks / 100.0

    potential_savings_kwh       = 52.0 * (@last_year_weekend_gas_kwh    - @average_weekend_gas_kwh)
    potential_savings_£         = 52.0 * (@last_weekend_cost_£          - @average_weekend_gas_£)
    potential_savings_£current  = 52.0 * (@last_weekend_cost_£current   - @average_weekend_gas_£current)
    potential_savings_co2       = 52.0 * (@last_weekend_cost_co2        - @average_weekend_gas_co2)

    assign_commmon_saving_variables(
      one_year_saving_kwh: potential_savings_kwh,
      one_year_saving_£: potential_savings_£current,
      capital_cost: 0.0,
      one_year_saving_co2: potential_savings_co2)

    @rating = @last_weekend_cost_£current < MAX_COST ? 10.0 : combined_rating

    @status = @rating < 5.0 ? :bad : :good

    @term = :shortterm
  end
  alias_method :analyse_private, :calculate

  private def previous_weekend_dates(asof_date)
    weekend_dates = []
    while weekend_dates.length < 2
      weekend_dates.push(asof_date) if weekend?(asof_date)
      asof_date -= 1
    end
    weekend_dates.sort
  end

  private def average_last_n_weekends_kwh(this_weekend_dates, datatype, n)
    dates = prior_weekend_dates(this_weekend_dates, n)
    kwh, _x, _y = kwh_usage_outside_frost_period(dates, FROST_PROTECTION_TEMPERATURE, datatype)
    kwh / n
  end

  private def prior_weekend_dates(this_weekend_dates, n)
    dates = []
    (1..n).each do |offset|
      dates.push(this_weekend_dates[0] - offset * 7)
      dates.push(this_weekend_dates[1] - offset * 7)
    end
    dates
  end

  private def weekend_gas_consumption_last_year(asof_date, datatype)
    start_date = meter_date_one_year_before(aggregate_meter, asof_date)
    annual_kwh = 0.0
    (start_date..asof_date).each do |date|
      annual_kwh += aggregate_meter.amr_data.one_day_kwh(date, datatype) if weekend?(date)
    end
    annual_kwh * scale_up_to_one_year(aggregate_meter, asof_date)
  end

  private def kwh_usage_outside_frost_period(dates, frost_protection_temperature, datatype)
    total_kwh = 0.0
    total_kwh_excluding_frost = 0.0
    frost_protection_hours = 0.0

    dates.each do |date|
      (0..47).each do |halfhour_index|
        val = @school.aggregated_heat_meters.amr_data.kwh(date, halfhour_index, datatype)
        if @school.temperatures.temperature(date, halfhour_index) > frost_protection_temperature
          total_kwh_excluding_frost += val
        else
          frost_protection_hours += 0.5
        end
        total_kwh += val
      end
    end

    [total_kwh_excluding_frost, frost_protection_hours, total_kwh]
  end
end
