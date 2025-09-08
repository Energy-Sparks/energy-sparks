#======================== Heating coming on too early in morning ==============
require_relative '../alert_gas_model_base.rb'

class AlertOptimumStartAnalysis < AlertGasModelBase
  attr_reader :regression_start_time, :optimum_start_sensitivity, :regression_r2
  attr_reader :average_start_time, :start_time_standard_devation, :average_start_time_hh_mm

  def initialize(school)
    super(school, :optimumstartanalysis)
    @relevance = :never_relevant if @relevance != :never_relevant && non_heating_only
  end

  def self.template_variables
    specific = {'Optimum start analysis' => TEMPLATE_VARIABLES}
    specific.merge(self.superclass.template_variables)
  end

  TEMPLATE_VARIABLES = {
    regression_start_time: {
      description:    'Boiler morning start time according to start v. temperature regression model',
      units:          :morning_start_time,
      benchmark_code: 'rmst'
    },
    optimum_start_sensitivity: {
      description:    'Sensitivity of start time versus temperature, i.e. the > the more likely optimum start is working',
      units:          :optimum_start_sensitivity,
      benchmark_code: 'rmss'
    },
    regression_r2: {
      description:    'r2 of start v. temperature regression model',
      units:          :r2,
      benchmark_code: 'rmr2'
    },
    average_start_time: {
      description:     'Average start time in morning',
      units:          :morning_start_time,
      benchmark_code: 'avgt'
    },
    average_start_time_hh_mm: {
      description:     'Average start time in morning',
      units:          :timeofday,
      benchmark_code: 'avhm'
    },
    start_time_standard_devation: {
      description:      'Standard deviation (hours) of start time in last year',
      units:            :opt_start_standard_deviation,
      benchmark_code:   'sdst'
    }
  }.freeze

  def timescale
    I18n.t("#{i18n_prefix}.timescale")
  end

  def enough_data
    days_amr_data >= 364 && enough_data_for_model_fit ? :enough : :not_enough
  end

  def calculate(asof_date)
    calculate_model(asof_date) # heating model call

    results = heating_model.optimum_start_analysis

    @regression_start_time        = results[:regression_start_time]
    @optimum_start_sensitivity    = results[:optimum_start_sensitivity]
    @regression_r2                = results[:regression_r2]
    @average_start_time           = results[:average_start_time]
    @average_start_time_hh_mm     = TimeOfDay.from_hour_fraction(@average_start_time)
    @start_time_standard_devation = results[:start_time_standard_devation]

    @rating = calculate_rating_from_range(6.0, 3.0, results[:average_start_time])

    @term = :longterm
  end
  alias_method :analyse_private, :calculate

  private
end
