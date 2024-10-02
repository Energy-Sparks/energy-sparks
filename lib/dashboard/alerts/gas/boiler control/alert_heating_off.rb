# typically fires in Spring when weather warm enough to turn heating off
class AlertTurnHeatingOff < AlertGasModelBase
  class MissingTemperatureData < StandardError; end
  attr_reader :last_year_cost_heating_in_warm_weather_kwh
  attr_reader :last_year_cost_heating_in_warm_weather_£
  attr_reader :last_year_cost_heating_in_warm_weather_co2
  attr_reader :last_year_heating_on_in_warm_weather_days
  attr_reader :future_degree_days, :horizon_start_date, :horizon_end_date
  attr_reader :future_saving_kwh, :future_saving_£, :future_saving_co2
  attr_reader :average_temperature, :average_day_temperature, :average_night_temperature
  attr_reader :up_to_annual_kwh, :percent_of_annual
  attr_reader :last_meter_reading_date, :days_since_last_meter_reading_date, :days_ago_plural

  def initialize(school, type = :turnheatingonoff)
    super(school, type)
    set_relevance
  end

  # ================================== Template Variables =========================================

  def self.template_variables
    specific = {'Turn heating off recommendations' => TEMPLATE_VARIABLES}
    specific.merge(self.superclass.template_variables)
  end

  TEMPLATE_VARIABLES = {
    last_year_cost_heating_in_warm_weather_kwh: {
      description: 'Annual (or less, meter years var) cost last year of leaving heating on in warm weather (kWh)',
      units:  :kwh
    },
    last_year_cost_heating_in_warm_weather_£: {
      description: 'Annual (or less, meter years var) cost last year of leaving heating on in warm weather (£) (historic tariff)',
      units:  :£
    },
    last_year_cost_heating_in_warm_weather_co2: {
      description: 'Annual (or less, meter years var) cost last year of leaving heating on in warm weather (co2)',
      units:  :co2
    },
    last_year_heating_on_in_warm_weather_days: {
      description: 'days heating on in warm weather last year',
      units:  Integer
    },
    historic_meter_years: {
      description: 'period of historic analysis up to 12 months available e.g. 6 months',
      units:  :years
    },
    future_degree_days: {
      description: 'degree days in horizon period',
      units:  :temperature
    },
    horizon_start_date: {
      description: 'start of future period savings assessed over',
      units:  Date
    },
    horizon_end_date: {
      description: 'end of future period savings assessed over',
      units:  Date
    },
    future_saving_kwh: {
      description: 'potential saving over future horizon period (kWh)',
      units:  :kwh
    },
    future_saving_£: {
      description: 'potential saving over future horizon period (£)',
      units:  :£
    },
    future_saving_co2: {
      description: 'potential saving over future horizon period (co2)',
      units:  :co2
    },
    average_temperature: {
      description: 'average forecast temperature',
      units:  :temperature
    },
    average_day_temperature: {
      description: 'average day time forecast temperature',
      units:  :temperature
    },
    average_night_temperature: {
      description: 'average forecast night time temperature',
      units:  :temperature
    },
    up_to_annual_kwh: {
      description: 'Annual kWh consumption - partial if less data is available',
      units:  :kwh
    },
    percent_of_annual: {
      description: 'warm weather consumption as a percentage of annual (or partial if not enough data)',
      units:  :percent
    },
    last_meter_reading_date: {
      description: 'date of last meter reading',
      units:  Date
    },
    days_since_last_meter_reading_date: {
      description: 'days since last meter reading date',
      units:  Integer
    },
    days_ago: {
      description: 'days since last meter read, including day/days',
      units: String
    },
    days_ago_plural: {
      description: 'set to s if days since last meter reading date > 1 so can say day or days ago',
      units:  String
    }
  }

  # ================================== Control Variables =========================================

  def timescale
    I18n.t("#{i18n_prefix}.timescale")
  end

  def enough_data
    enough_data_for_model_fit ? :enough : :not_enough
  end

  def time_of_year_relevance
    in_season?(@today) ? (10.0 - (@rating / 2)) : 0.0
  end

  protected def max_days_out_of_date_while_still_relevant
    7
  end

  private

  def set_relevance
    if @relevance != :never_relevant
      asof_date = [@asof_date, aggregate_meter.nil? ? nil : aggregate_meter.amr_data.end_date].compact.first
      rel = in_season?(@today) && recent_data? && enough_data_for_model_fit(asof_date) && heating_on_in_last_5_days?
      @relevance = rel ? :relevant : :never_relevant
    end
  end

  # reduce season forecast queried for to save costs
  # check env variable so always run in test environment
  def in_season?(today)
    td = !ENV['ENERGYSPARKSTODAY'].nil? ? Date.parse(ENV['ENERGYSPARKSTODAY']) :  today
    td.month.between?(3, 10)
  end

  # ================================== Calculation ==============================================

  def calculate(asof_date)
    # its important that 'today' is the rundate (@asof_date)and not the last meter date (asof_date)
    # in the test environment should have already been set from ENV['ENERGYSPARKSTODAY']
    @today = @asof_date

    calculate_model(asof_date)

    calculate_historic_benefit(asof_date)

    calculate_forecast_benefit(@today)

    assign_commmon_saving_variables(
      one_year_saving_kwh: @future_saving_kwh,
      one_year_saving_£: @future_saving_£,
      capital_cost: 0.0,
      one_year_saving_co2: @future_saving_co2)

    set_up_to_dateness_of_meter

    @rating = calculate_rating_from_range(0, 1.5, @future_degree_days / @horizon_days)

    @term = :shortterm
  end
  alias_method :analyse_private, :calculate

  def days_ago
    FormatUnit.format(:days, @days_since_last_meter_reading_date)
  end

  def set_up_to_dateness_of_meter
    @last_meter_reading_date = aggregate_meter.amr_data.end_date
    @days_since_last_meter_reading_date = (@today - @last_meter_reading_date).to_i
    #DONT USE
    @days_ago_plural = @days_since_last_meter_reading_date == 1 ? '' : 's'
  end

  # ================================== Future Analysis ==========================================

  def calculate_forecast_benefit(today)
    horizon_date = analysis_horizon_date(@today)
    forecast = load_forecast_temperatures(@today)

    future_date_range = calculate_future_date_range(forecast, @today, horizon_date)

    @future_degree_days = future_degreedays(forecast, future_date_range)
    @future_saving_kwh  = predicted_savings_kwh(forecast, future_date_range)
    @future_saving_£    = @future_saving_kwh * aggregate_meter.amr_data.current_tariff_rate_£_per_kwh
    @future_saving_co2  = gas_co2(@future_saving_kwh)
    @horizon_start_date = future_date_range.first
    @horizon_end_date   = future_date_range.last
    @horizon_days       = (future_date_range.last - future_date_range.first).to_i

    @average_temperature        = average_forecast_temperature(forecast, future_date_range,  0, 24)
    @average_day_temperature    = average_forecast_temperature(forecast, future_date_range, 10, 15)
    @average_night_temperature  = average_forecast_temperature(forecast, future_date_range,  0,  5)
  end

  def load_forecast_temperatures(horizon_date)
    WeatherForecast.nearest_cached_forecast_factory(horizon_date, @school.latitude, @school.longitude)
  end

  # ignore school day type e.g. weekends holidays for calculation
  def future_degreedays(forecast, future_date_range)
    temperatures = forecast_temperatures(forecast, future_date_range, 0, 24)

    temperatures.values.map { |t| [0.0, t - balance_point_temperature].max }.sum
  end

  def average_forecast_temperature(forecast, future_date_range, start_hour, end_hour)
    temperatures = forecast_temperatures(forecast, future_date_range, start_hour, end_hour)
    temperatures.values.sum / temperatures.length
  end

  def balance_point_temperature
    AnalyseHeatingAndHotWater::HeatingModelTemperatureSpace::BALANCE_POINT_TEMPERATURE
  end

  def warm?(temperature)
    temperature > balance_point_temperature
  end

  def forecast_temperatures(forecast, future_date_range, start_hour, end_hour)
    future_date_range.map do |date|
      [date, forecast.average_temperature_within_hours(date, start_hour, end_hour)]
    end.to_h
  end

  def calculate_future_date_range(forecast, start_date, end_date)
    Range.new([forecast.start_date, start_date].max, [forecast.end_date, end_date].min)
  end

  def predicted_savings_kwh(forecast, future_date_range)
    temperatures = forecast_temperatures(forecast, future_date_range, 0, 24)

    temperatures.map do |date, temperature|
      warm?(temperature) ? heating_model.predicted_heating_kwh_future_date(date, temperature) : 0.0
    end.sum
  end

  # at weekend just look forward to the coming week
  # for weekdays look forward to the Saturday of the week afterwards
  def analysis_horizon_date(asof_date)
    case asof_date.wday
    when 0, 6
      asof_date.next_occurring(:saturday)
    when 1..5
      asof_date.next_occurring(:saturday).next_occurring(:saturday)
    end
  end

  # ================================== Historic Analysis ==========================================

  def recent_data?
    @today - aggregate_meter.amr_data.end_date < max_days_out_of_date_while_still_relevant
  end

  def heating_on_in_last_5_days?
    ed = aggregate_meter.amr_data.end_date
    model = calculate_model(aggregate_meter.amr_data.end_date)
    sd = [ed - 4, aggregate_meter.amr_data.start_date].max
    (sd..ed).any?{ |date| model.heating_on?(date) }
  end

  def calculate_historic_benefit(asof_date)
    @last_year_cost_heating_in_warm_weather_kwh   = historic_warm_weather_benefit(asof_date, :kwh)
    @last_year_cost_heating_in_warm_weather_£     = historic_warm_weather_benefit(asof_date, :£)
    @last_year_cost_heating_in_warm_weather_co2   = historic_warm_weather_benefit(asof_date, :co2)
    @last_year_heating_on_in_warm_weather_days    = historic_warm_weather_benefit(asof_date, :days)
    @up_to_annual_kwh                             = calculate_up_to_annual_kwh(aggregate_meter, asof_date)
    @percent_of_annual = @up_to_annual_kwh == 0.0 ? 0.0 : (@last_year_cost_heating_in_warm_weather_kwh / @up_to_annual_kwh)
  end

  # not necessarily 100% coincident with heating_on_seasonal_analysis()
  def historic_meter_analysis_period(asof_date)
    ed = [aggregate_meter.amr_data.end_date, asof_date].min
    sd = [ed - 365, aggregate_meter.amr_data.start_date].max
    sd..ed
  end

  def historic_warm_weather_benefit(asof_date, data_type)
    aggregate_analysis(asof_date, :heating_warm_weather, data_type)
  end

  def aggregate_analysis(asof_date, heating_type, value_type)
    seasonal_analysis(asof_date).values.map do |by_heating_regime_data|
      by_heating_regime_data.dig(heating_type, value_type)
    end.compact.sum
  end

  def seasonal_analysis(asof_date)
    @seasonal_analysis ||= @heating_model.heating_on_seasonal_analysis(end_date: asof_date)
  end
end
