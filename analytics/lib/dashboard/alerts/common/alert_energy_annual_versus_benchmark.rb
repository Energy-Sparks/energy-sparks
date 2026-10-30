require_relative 'alert_analysis_base'
require_relative 'alert_floor_area_mixin'
require_relative 'template_var_promotion_mix_in'
require_relative 'change_in_energy_use'

class AlertEnergyAnnualVersusBenchmark < AlertAnalysisBase
  include Logging
  include TemplateVarPromotionMixIn

  attr_reader :last_year_kwh, :last_year_£, :last_year_£current, :last_year_co2, :last_year_co2_tonnes
  attr_reader :one_year_energy_per_pupil_kwh, :one_year_energy_per_pupil_£, :one_year_energy_per_pupil_co2
  attr_reader :one_year_energy_per_floor_area_kwh, :one_year_energy_per_floor_area_£, :one_year_energy_per_floor_area_co2
  attr_reader :percent_difference_from_average_per_pupil
  attr_reader :trees_co2
  attr_reader :change_in_energy_use_since_joined_percent, :change_in_electricity_use_since_joined_percent
  attr_reader :change_in_gas_use_since_joined_percent, :change_in_storage_heater_use_since_joined_percent
  attr_reader :last_year_electricity_co2, :last_year_gas_co2
  attr_reader :last_year_storage_heater_co2, :last_year_solar_pv_co2
  attr_reader :solar_type
  attr_reader :recent_fuel_types_for_debug

  def initialize(school)
    super(school, :annualenergybenchmark)
    # set_template_variables_as_attr_reader(TEMPLATE_VARIABLES)
    @relevance = :relevant
  end

  def self.template_variables
    static_and_dymamic_variables = TEMPLATE_VARIABLES.merge(ChangeInEnergyUseSymbols.template_variables)
    specific = {'Overall annual energy' => static_and_dymamic_variables }
    specific.merge(self.superclass.template_variables)
  end

  def timescale
    I18n.t("#{i18n_prefix}.timescale")
  end

  def enough_data
    @school.all_aggregate_meters.any?{ |meter| meter.amr_data.days_valid_data > 364 } ? :enough : :not_enough
  end

  def no_single_aggregate_meter
    true
  end

  def maximum_alert_date
    # @school.all_aggregate_meters.map { |meter| meter.amr_data.end_date }.max
    # this energy benchmark now works across multiple meters indepedently and flags
    # up when meter data is out of date, therefore work to as asof date rather
    # than the oldest last meter date
    @asof_date
  end

  TEMPLATE_VARIABLES = {
    last_year_kwh: {
      description: 'Last years energy consumption - kwh',
      units:  {kwh: :electricity},
      benchmark_code: 'klyr',
      # calc: ->{ scalar({ year: 0}, :energy_ex_solar, :kwh) }
    },
    last_year_£: {
      description: 'Last years energy consumption - £ including differential tariff (historic tariffs)',
      units:  :£,
      benchmark_code: '£lyr'
    },
    last_year_£current: {
      description: 'Last years energy consumption - £ including differential tariff (latest tariffs)',
      units:  :£current,
      benchmark_code: '€lyr'
    },
    last_year_co2: {
      description: 'Last years energy CO2 kg',
      units:  :co2,
      benchmark_code: 'co2y'
    },
    last_year_co2_tonnes: {
      description: 'Last years energy CO2 tonnes',
      units:  :co2t,
      benchmark_code: 'co2t'
    },
    last_year_electricity_co2: {
      description: 'Last years electricity CO2 kg',
      units:  :co2,
      benchmark_code: 'co2e'
    },
    last_year_gas_co2: {
      description: 'Last years gas CO2 kg',
      units:  :co2,
      benchmark_code: 'co2g'
    },
    last_year_storage_heater_co2: {
      description: 'Last years storage heater CO2 kg',
      units:  :co2,
      benchmark_code: 'co2h'
    },
    last_year_solar_pv_co2: {
      description: 'Last years solar CO2 kg',
      units:  :co2,
      benchmark_code: 'co2s'
    },
    one_year_energy_per_pupil_kwh: {
      description: 'Per pupil annual energy usage - kwh',
      units:  :kwh,
      benchmark_code: 'kpup'
    },
    one_year_energy_per_pupil_£: {
      description: 'Per pupil annual energy usage - £',
      units:  :£,
      benchmark_code: '£pup'
    },
    one_year_energy_per_pupil_co2: {
      description: 'Per pupil annual energy usage - co2',
      units:  :co2,
      benchmark_code: 'cpup'
    },
    one_year_energy_per_floor_area_kwh: {
      description: 'Per floor area annual energy usage - kwh',
      units:  :kwh,
      benchmark_code: 'kfla'
    },
    one_year_energy_per_floor_area_£: {
      description: 'Per floor area annual energy usage - £',
      units:  :£,
      benchmark_code: '£fla'
    },
    one_year_energy_per_floor_area_co2: {
      description: 'Per floor area annual energy usage - co2',
      units:  :co2,
      benchmark_code: 'cfla'
    },
    percent_difference_from_average_per_pupil: {
      description: 'Percent difference from average',
      units:  :relative_percent,
      benchmark_code: 'pp%d'
    },
    percent_difference_adjective: {
      description: 'Adjective relative to average: above, signifantly above, about',
      units: String
    },
    simple_percent_difference_adjective:  {
      description: 'Adjective relative to average: above, about, below',
      units: String
    },
    summary: {
      description: 'Description: £spend/yr',
      units: String
    },
    trees_co2: {
      description: 'Number of trees (40 years) equivalence of CO2',
      units:  :tree
    },
    recent_fuel_types_for_debug: {
      description: 'Debugging information - list of up to date fuel types',
      units:  String
    },
    solar_type: {
      description: 'Solar type - metered or synthetic',
      units:  String,
      benchmark_code: 'solr'
    }
  }

  def trees_electricity
    @school.electricity? ? EnergyConversions.new(@school).front_end_convert(:tree_co2_tree, timescale, :allelectricity_unmodified)[:equivalence] : 0.0
  end

  def trees_gas
    @school.gas? ? EnergyConversions.new(@school).front_end_convert(:tree_co2_tree, timescale, :gas)[:equivalence] : 0.0
  end

  def trees
    trees_electricity + trees_gas
  end

  def trees_description
    trees_numbers = trees.round(0).to_i
    "#{trees_numbers} trees"
  end

  def calculate(asof_date)
    change_in_energy = ChangeInEnergyUse.new(@school, asof_date)

    res = change_in_energy.calculate

    set_template_variables(res)

    @solar_type = calculate_solar_type

    assign_legacy_variables

    available_recent_fuel_types = fuel_types_with_up_to_date_data_in_last_year(asof_date)
    logger.info "Benchmarking versus these recent fuel_types: #{available_recent_fuel_types.join(',')}"
    raise EnergySparksNotEnoughDataException, 'Zero up to date meter data (by fuel type)' if available_recent_fuel_types.empty?
    @recent_fuel_types_for_debug = available_recent_fuel_types.join(',')

    #these all calculate a kwh per pupil or floor area figure
    @one_year_energy_per_pupil_kwh      = change_in_energy.calculate_normalised_energy({year: 0}, :kwh, :number_of_pupils)
    @one_year_energy_per_floor_area_kwh = change_in_energy.calculate_normalised_energy({year: 0}, :kwh, :floor_area)

    @one_year_energy_per_pupil_£        = change_in_energy.calculate_normalised_energy({year: 0}, :£,   :number_of_pupils)
    @one_year_energy_per_floor_area_£   = change_in_energy.calculate_normalised_energy({year: 0}, :£,   :floor_area)

    @one_year_energy_per_pupil_co2      = change_in_energy.calculate_normalised_energy({year: 0}, :co2, :number_of_pupils)
    @one_year_energy_per_floor_area_co2 = change_in_energy.calculate_normalised_energy({year: 0}, :co2, :floor_area)

    #this is a £ per pupil across all fuel types
    per_pupil_energy_benchmark_£ = BenchmarkMetrics.benchmark_energy_usage_£_per_pupil(:benchmark, @school, asof_date, available_recent_fuel_types)
    per_pupil_energy_exemplar_£  = BenchmarkMetrics.benchmark_energy_usage_£_per_pupil(:exemplar, @school, asof_date, available_recent_fuel_types)

    @percent_difference_from_average_per_pupil = percent_change(per_pupil_energy_benchmark_£, @one_year_energy_per_pupil_£)

    #BACKWARDS COMPATIBILITY: previously would have failed here as percent_change can return nil
    raise_calculation_error_if_missing(percent_difference_from_average_per_pupil: @percent_difference_from_average_per_pupil)
    @trees_co2 = trees

    @rating = calculate_rating_from_range(per_pupil_energy_exemplar_£, per_pupil_energy_benchmark_£ * 1.2, @one_year_energy_per_pupil_£)
  end
  alias_method :analyse_private, :calculate

  def percent_difference_adjective
    @percent_difference_from_average_per_pupil.nil? ? "" : Adjective.relative(@percent_difference_from_average_per_pupil, :relative_to_1)
  end

  def simple_percent_difference_adjective
    @percent_difference_from_average_per_pupil.nil? ? "" : Adjective.relative(@percent_difference_from_average_per_pupil, :simple_relative_to_1)
  end

  private

  # string matching in benchmark_configuration.rb so careful when translating!
  # PH wouldn't translate as used for keying tables
  def calculate_solar_type
    if @school.sheffield_simulated_solar_pv_panels?
      'synthetic'
    elsif @school.solar_pv_real_metering?
      'metered'
    else
      ''
    end
  end

  private def log_missing_variable(type)
    # do nothing, overriding base class, as this alert
    # produces different variables depending on the fuel
    # types available, so for most schools storage heater
    # and solar PV variables will be missing
    # as the variables are defined on the class and not the instance
    # there is no easy way around this issue
    # TODO(PH, 2Nov2020) - is there a better way of dealing with this?
    @missing_variables ||= []
    @missing_variables.push(type)
  end

  private def missing_variable_summary
    return if @missing_variables.nil?
    missing_solar_pv        = @missing_variables.count{ |var| var.to_s.include?('solar') }
    missing_storage_heaters = @missing_variables.count{ |var| var.to_s.include?('storage') }
    the_rest = @missing_variables.select{ |var| !var.to_s.include?('solar') && !var.to_s.include?('storage') }
    logger.info "Comment: alert doesnt implement #{missing_solar_pv} solar variables and #{missing_storage_heaters} storage heater variables"
    the_rest.each do |var|
      logger.info "Warning: alert doesnt implement #{var}"
    end
  end

  def assign_legacy_variables
    # backwards compatibility TODO(PH, 10Oct2020) - remove and change references in calling code
    @last_year_kwh                = @current_year_energy_kwh
    @last_year_£                  = @current_year_energy_£
    @last_year_£current           = @current_year_energy_£current
    @last_year_solar_pv_co2       = @current_year_solar_pv_co2
    @last_year_co2                = @current_year_energy_co2
    @last_year_co2_tonnes         = @current_year_energy_co2.nil? ? nil : @current_year_energy_co2 / 1000.0

    @last_year_electricity_co2    = @current_year_electricity_co2
    @last_year_gas_co2            = @current_year_gas_co2
    @last_year_storage_heater_co2 = @current_year_storage_heaters_co2
  end

  def summary
    if @last_year_£
      I18n.t("analytics.common.pa", cost: FormatUnit.format(:£, @last_year_£, :text))
    else
      ""
    end
  end

  def fuel_types_with_up_to_date_data_in_last_year(asof_date)
    chg = ChangeInEnergyUse.new(@school, asof_date)
    available_data = chg.data_available({year: 0}, {year: 0}, true)
    available_data[:aggregate]
  end
end
