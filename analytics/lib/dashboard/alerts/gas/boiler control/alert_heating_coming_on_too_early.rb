#======================== Heating coming on too early in morning ==============
require_relative '../alert_gas_model_base.rb'

class AlertHeatingComingOnTooEarly < AlertGasModelBase
  #Also defined in base class?
  FROST_PROTECTION_TEMPERATURE = 4
  #Unused?
  MAX_HALFHOURS_HEATING_ON = 10

  attr_reader :last_year_kwh, :last_year_£
  attr_reader :heating_on_times_table

  attr_reader :one_year_optimum_start_saving_kwh, :one_year_optimum_start_saving_£, :one_year_optimum_start_saving_co2
  attr_reader :one_year_optimum_start_saving_£current
  attr_reader :percent_of_annual_gas, :avg_week_start_time

  def initialize(school)
    super(school, :heatingcomingontooearly)
    @relevance = :never_relevant if holiday?(@today)
  end

  def self.template_variables
    specific = {'Heating coming on too early' => TEMPLATE_VARIABLES}
    specific.merge(self.superclass.template_variables)
  end

  protected def max_days_out_of_date_while_still_relevant
    21
  end

  TEMPLATE_VARIABLES = {
    heating_on_times_table: {
      description: 'Last 7 days, heating on times and recommended heating start times with optimal start control and frost protection',
      units: :table,
      header: ['Date', 'Heating on time', 'Recommended on time', 'Overnight temperature', 'Timing', 'Potential Saving (kWh)', 'Potential Saving (£)', 'Potential Saving (CO2kg)'],
      column_types: [:date, TimeOfDay, TimeOfDay, :temperature, String, { kwh: :gas }, :£, :co2]
    },
    one_year_optimum_start_saving_kwh: {
      description: 'Estimates (up to saving) of benefit of starting boiler later in morning using a crude optimum start and frost model - kWh',
      units:  {kwh: :gas}
    },
    one_year_optimum_start_saving_£: {
      description: 'Estimates (up to saving) of benefit of starting boiler later in morning using a crude optimum start and frost model - £ historic tariff',
      units:  :£,
      benchmark_code: 'oss£'
    },
    one_year_optimum_start_saving_£current: {
      description: 'Estimates (up to saving) of benefit of starting boiler later in morning using a crude optimum start and frost model - £ latest tariff',
      units:  :£,
      benchmark_code: 'oss€'
    },
    one_year_optimum_start_saving_co2: {
      description: 'Estimates CO2 (up to saving) of benefit of starting boiler later in morning using a crude optimum start and frost model - CO2',
      units:  :co2
    },
    avg_week_start_time: {
      description: 'Average time heating started in last week',
      units: :timeofday,
      benchmark_code: 'htst'
    },
    percent_of_annual_gas: {
      description: 'Percent of annual gas consumption lost through coming on too early versus optimal start/frost',
      units:  :percent
    },
    annual_heating_day_intraday_profile_gas_chart: {
      description: 'Intraday profile of annual usage (£) - only heating days, not summer',
      units: :chart
    },
    last_7_days_gas_chart: {
      description: 'Last 7 days gas consumption and temperatures (suggest to user clicking off legend)',
      units: :chart
    },
  }.freeze

  def timescale
    I18n.t("#{i18n_prefix}.timescale")
  end

  def enough_data
    days_amr_data >= 7 && enough_data_for_model_fit ? :enough : :not_enough
  end

  def last_7_days_gas_chart
    :alert_last_7_days_intraday_gas_heating_on_too_early
  end

  def annual_heating_day_intraday_profile_gas_chart
    :alert_gas_heating_season_intraday
  end

  def calculate(asof_date)
    calculate_model(asof_date) # heating model call

    @heating_on_times_table, rating_7_day, @avg_week_start_time = heating_on_time_assessment(asof_date)

    @one_year_optimum_start_saving_kwh, @percent_of_annual_gas = hm_1_year_saving(asof_date, :kwh)
    @one_year_optimum_start_saving_£, _p                       = hm_1_year_saving(asof_date, :£)
    @one_year_optimum_start_saving_£current, _p                = hm_1_year_saving(asof_date, :£current)
    @one_year_optimum_start_saving_co2, _p                     = hm_1_year_saving(asof_date, :co2)

    assign_commmon_saving_variables(
      one_year_saving_kwh: @one_year_optimum_start_saving_kwh,
      one_year_saving_£: Range.new(0.0, @one_year_optimum_start_saving_£current),
      capital_cost: Range.new(0.0, 700.0),
      one_year_saving_co2: @one_year_optimum_start_saving_co2)

    @rating = calculate_rating_from_range(1.0, 0.0, rating_7_day)

    @status = @rating.to_f < 7.0 ? :bad : :good

    @term = :shortterm
  end
  alias_method :analyse_private, :calculate

  private

  def hm_1_year_saving(asof_date, datatype)
    heating_model.one_year_saving_from_better_boiler_start_time(asof_date, datatype)
  end

  private def heating_on_time_assessment(asof_date, days_countback = 7)
    HeatingStartTimeCalculator.new(heating_model: heating_model).calculate_start_times(asof_date, days_countback)
  end
end
