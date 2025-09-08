require_relative 'alert_floor_area_pupils_mixin.rb'
# to reduce class clutter
# TODO(PH 10Oct2020) needs further work as @attributes doesn't work as mixin only if as a class
module TemplateVarPromotionMixIn
  def self.execute_variables(template_variables)
    template_variables.select{ |var, val| val.key?(:calc)}.each do |var, val|
      if instance_variable_get("@#{var}").nil?
        d = instance_exec(&val[:calc])
        instance_variable_set("@#{var}", d)
      end
    end
  end

  def self.attr_reader(*vars)
    @attributes ||= []
    @attributes.concat vars
    super(*vars)
  end

  def self.attributes
    @attributes
  end

  def attributes
    self.class.attributes
  end

  def set_template_variables_as_attr_reader(vars)
    vars.keys.each do |var|
      self.class.send(:attr_reader, var) if !check || attributes.nil? || !attributes.include?(var)
    end
  end

  def set_template_variables(vars)
    vars.each do |name, value|
      new_template_variable(name, value)
    end
  end

  def new_template_variable(name, value)
    self.class.send(:attr_reader, name)
    instance_variable_set("@#{name}", value)
  end
end

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
      I18n.t("analytics.common.pa", cost: FormatEnergyUnit.format(:£, @last_year_£, :text))
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

class ChangeInEnergyUse < AlertAnalysisBase
  def initialize(school, asof_date)
    @school = school
    @asof_date = asof_date
  end

  def calculate
    results = {}
    variable_stub = nil

    ChangeInEnergyUseSymbols::DATA_TYPES.each do |datatype, _type_code|
      [[{year: 0}, {year: -1}], [{year: 0}, {activationyear: 0}]].each do |(period1, period2)|
        comparison = {}
        raw_data = []
        available_data = data_available(period2, period1)
        @school.fuel_types(false, false).each do |fuel_type, _fuel_code|
          next if ChangeInEnergyUseSymbols.exclude_solar_costs?(datatype, fuel_type)
          symbolic, raw = calculate_change_between_periods(period1, period2, variable_stub, fuel_type, datatype, available_data)
          comparison.merge!(symbolic)
          raw_data.push(raw)
        end
        results.merge!(comparison)
        result = aggregate_fuels(raw_data, period1, period2, available_data[:aggregate], datatype, variable_stub)
        results.merge!(result)
      end
    end
    results
  end

  # optimisation, calculate normalised energy from already calculated
  # constituent fuel types, has to be normalised first for each fuel
  # type as the (partial) floor_area s and number_of_pupil s might
  # differ for each fuel type in the case of partial metering
  # - deprecated as doesn't sync data correctly
  def calculate_normalised_energy(period, datatype, normalisation)
    @school.fuel_types(false, false).map do |fuel_type, _fuel_code|
      next if ChangeInEnergyUseSymbols.exclude_solar_costs?(datatype, fuel_type)
      available_data = data_available(period, period, true)
      next unless available_data[:aggregate].include?(fuel_type)
      symbol = ChangeInEnergyUseSymbols.symbol(nil, period, fuel_type, datatype)
      res = precalculated_value(symbol)
      norm_key = normalisation_key(normalisation)
      res[norm_key]
    end.compact.sum
  end

  def normalisation_key(normalisation)
    if normalisation == :floor_area
      :value_per_floor_area
    elsif normalisation == :number_of_pupils
      :value_per_pupil
    elsif normalisation.nil?
      raise EnergySparksUnexpectedStateException, 'nil normalisation symbol'
    else
      raise EnergySparksUnexpectedStateException, "Unexpected normalisation symbol #{normalisation}"
    end
  end

  # calculates and sets instance variables/attributes for energy use between
  # 2 periods
  def calculate_change_between_periods(current_period, previous_period, variable_stub, fuel_type, datatype, available_data)
    sym_v1 = ChangeInEnergyUseSymbols.symbol(variable_stub, current_period, fuel_type, datatype)
    v1 = calculate_variable(sym_v1, current_period,  fuel_type, datatype)

    sym_v0 = ChangeInEnergyUseSymbols.symbol(variable_stub, previous_period, fuel_type, datatype)
    v0 = calculate_variable(sym_v0, previous_period, fuel_type, datatype)

    p = percent_change(to_nil_value(v0), to_nil_value(v1))
    sym_p = ChangeInEnergyUseSymbols.symbol(variable_stub, previous_period, fuel_type, datatype, :relative_percent)

    v1, v0, p = label_missing_data(to_nil_value(v1), to_nil_value(v0), p, fuel_type, available_data)

    [
      {
        sym_v1  => v1,
        sym_v0  => v0,
        sym_p   => p,
      },
      {
        current:    v1,
        previous:   v0,
        fuel_type:  fuel_type
      }
    ]
  end

  def to_nil_value(result)
    result.nil? ? nil : result[:value]
  end

  def calculate_variable(symbol, period, fuel_type, datatype)
    @cached_calculations ||= {}
    @cached_calculations[symbol] ||= scalar(period, fuel_type, datatype)
  end

  def precalculated_value(symbol)
    @cached_calculations[symbol]
  end

  def label_missing_data(cp, pp, percent, fuel_type, available_data)
    if available_data[:not_recent].include?(fuel_type)
      # represent current period as previous period, current period as 'no recent data'
      pp = cp
      cp = nil
      percent = ManagementSummaryTable::NO_RECENT_DATA_MESSAGE
    end
    if available_data[:not_enough].include?(fuel_type)
      # show both periods but label percent to indicate the problem (periods overlap)
      percent = ManagementSummaryTable::NOT_ENOUGH_DATA_MESSAGE
    end
    [cp, pp, percent]
  end

  def aggregate_fuels(fuel_data, current_period, previous_period, fuels_to_aggregate, datatype, variable_stub)
    sym_v1 = ChangeInEnergyUseSymbols.symbol(variable_stub, current_period,  :energy, datatype)
    sym_v0 = ChangeInEnergyUseSymbols.symbol(variable_stub, previous_period, :energy, datatype)
    sym_p  = ChangeInEnergyUseSymbols.symbol(variable_stub, previous_period, :energy, datatype, :relative_percent)

    aggregated_fuels = aggregate_fuel_type(fuel_data)

    # will pick up case where can calculate a year's data for each period
    # but periods overlap so percentatge comparison invalid
    calculated_fuel_types = fuel_data.map{ |data| data[:fuel_type] }
    both_periods_valid_data = fuels_to_aggregate.sort == calculated_fuel_types.sort

    {
      sym_v1  => aggregated_fuels[:current],
      sym_v0  => aggregated_fuels[:previous],
      sym_p   => both_periods_valid_data ? percent_change(aggregated_fuels[:previous], aggregated_fuels[:current]) : nil
    }
  end

  # only want to aggregate data where there is a full set of expected
  # fuel types during the period
  # TODO(PH, 4Nov2020) consider whether this is valid if a school is transitioning
  #                    off 1 fuel type onto another e.g. gas to electric heating?
  def aggregate_fuel_type(fuel_data)
    full_set_current_data  = fuel_data.all?{ |data_for_fuel_type| !data_for_fuel_type[:current].nil?  }
    full_set_previous_data = fuel_data.all?{ |data_for_fuel_type| !data_for_fuel_type[:previous].nil? }
    {
      current:   full_set_current_data  ? sum_period_data(fuel_data, :current)  : nil,
      previous:  full_set_previous_data ? sum_period_data(fuel_data, :previous) : nil,
    }
  end

  def sum_period_data(fuel_data, period_type)
    # map then sum to avoid statsample bug
    fuel_data.map{ |data_for_fuel_type| data_for_fuel_type[period_type] }.sum
  end

  def aggregate_fuel_deprecated(fuel_data, fuels_to_aggregate, period_type)
    # map then sum to avoid statsample bug
    fuel_data.map{ |fuel| fuels_to_aggregate.include?(fuel[:fuel_type]) ? fuel[period_type] : 0.0 }.sum
  end

  def data_available(period2, period1, allow_overlapping_periods = false)
    fuels_to_aggregate = FuelTypesToAggregate.new(@school, @asof_date, period2, period1, allow_overlapping_periods)
    fuels_to_aggregate.calculate
    fuels_to_aggregate.data
  end

  def set_var(symbol, value)
    new_template_variable(symbol, value)
  end

  def scalar(timescale, fuel_type, datatype)
    scale = CalculateAggregateValues.new(@school)
    begin
      scale.scalar(timescale, fuel_type, datatype)
    rescue EnergySparksNotEnoughDataException => _e
      nil
    end
  end

  # the logic for this nested class is a bit tortuous
  # basically there needs to be enough (2 year periods) and recent (< 90 days out of date) data
  # for each fuel type for the data to be aggregated for the 'energy' total
  # when it calculates for :electricity it assumes storage heaters and solar pv
  # have same start_dates, end_dates
  class FuelTypesToAggregate
    attr_reader :fuels_for_aggregation
    attr_reader :fuels_for_non_aggregation_because_of_no_recent_data
    attr_reader :fuels_for_non_aggregation_because_of_not_enough_data

    def initialize(school, asof_date, first_period, last_period, allow_overlapping_periods = false)
      @school = school
      @asof_date = asof_date
      @first_period = first_period
      @last_period = last_period
      @allow_overlapping_periods = allow_overlapping_periods
      @fuels_for_aggregation = []
      @fuels_for_non_aggregation_because_of_no_recent_data = []
      @fuels_for_non_aggregation_because_of_not_enough_data = []
      @basic_fuel_types = @school.fuel_types # only electric gas, ignore storage and solar as added later as they follow rules for underlying electricity meter
    end

    def calculate
      reject_fuels_with_no_recent_data
      reject_fuels_with_not_enough_data
      include_with_electric(:storage_heaters)
      include_with_electric(:solar_pv)
    end

    def data
      {
        aggregate:  @fuels_for_aggregation,
        not_recent: @fuels_for_non_aggregation_because_of_no_recent_data,
        not_enough: @fuels_for_non_aggregation_because_of_not_enough_data
      }
    end

    private

    def reject_fuels_with_no_recent_data
      @basic_fuel_types.each do |fuel_type|
        reject_fuel_type_with_no_recent_data(fuel_type)
      end
    end

    def reject_fuels_with_not_enough_data
      @basic_fuel_types.each do |fuel_type|
        reject_fuel_type_with_not_enough_data(fuel_type)
      end
    end

    def no_recent_data(fuel_type)
      meter = @school.aggregate_meter(fuel_type)
      meter.amr_data.end_date < @asof_date - ManagementSummaryTable::MAX_DAYS_OUT_OF_DATE_FOR_1_YEAR_COMPARISON
    end

    def reject_fuel_type_with_no_recent_data(fuel_type)
      if no_recent_data(fuel_type)
        fuels_for_non_aggregation_because_of_no_recent_data.push(fuel_type)
        fuels_for_aggregation.delete(fuel_type)
      else
        fuels_for_aggregation.push(fuel_type)
      end
    end

    def reject_fuel_type_with_not_enough_data(fuel_type)
      if fuels_for_aggregation.include?(fuel_type) && !enough_data?(fuel_type)
        fuels_for_non_aggregation_because_of_not_enough_data.push(fuel_type)
        fuels_for_aggregation.delete(fuel_type)
      end
    end

    def enough_data?(fuel_type)
      amr_data = @school.aggregate_meter(fuel_type).amr_data
      p1 = period_dates(@first_period, amr_data)
      p2 = period_dates(@last_period,  amr_data)
      if @allow_overlapping_periods
        !p1.nil? && !p2.nil?
      else
        !p1.nil? && !p2.nil? && p2[0] > p1[1]
      end
    end

    def period_dates(timescale, amr_data)
      begin
        end_date = [amr_data.end_date, @asof_date].min
        PeriodsBase.period_dates(timescale, @school, amr_data.start_date, end_date)
      rescue EnergySparksNotEnoughDataException => _e
        nil
      end
    end

    def include_with_electric(fuel_type)
      include_with_electric_if_on_list(fuels_for_aggregation, fuel_type)
      include_with_electric_if_on_list(fuels_for_non_aggregation_because_of_no_recent_data, fuel_type)
      include_with_electric_if_on_list(fuels_for_non_aggregation_because_of_not_enough_data, fuel_type)
    end

    def include_with_electric_if_on_list(list, fuel_type)
      fuel_types = @school.fuel_types(false, false)
      if fuel_types.include?(fuel_type)
        if list.include?(:electricity)
          list.push(fuel_type)
        end
      end
    end
  end
end

# generate unique template variables and benchmark codes for 75 different variables
# see list of symbols and benchmark codes in comments below
class ChangeInEnergyUseSymbols
  # mappings to benchmark codes for these
  DATA_TYPES = { kwh: 'k', co2: 'c', £: 'p', £current: '€'}
  METER_TYPES = { electricity: 'e', gas: 'g', storage_heaters: 'h', solar_pv: 's' }

  def self.template_variables
    vars = []
    [[{year: 0}, {year: -1}], [{year: 0}, {activationyear: 0}]].each do |(current_period, previous_period)|
      DATA_TYPES.each do |datatype, _type_code|
        meter_types = METER_TYPES.keys + [:energy]
        meter_types.each do |fuel_type, _fuel_code|
          next if exclude_solar_costs?(datatype, fuel_type)
          sym_v1 = calc_template_variable(nil, current_period,  fuel_type, datatype, '')
          sym_v0 = calc_template_variable(nil, previous_period, fuel_type, datatype, '')
          sym_p  = calc_template_variable(nil, previous_period, fuel_type, datatype, '', :relative_percent)
          vars += [sym_v1, sym_v0, sym_p]
        end
      end
    end
    vars.inject(:merge) # convert array of hashs to a single hash
  end

  def self.exclude_solar_costs?(datatype, fuel_type)
    datatype == :£ && fuel_type == :solar_pv # we don;t have consistent solar costs PH 12Oct2020
  end

  def self.print_benchmark_codes
    vars = template_variables.transform_values{ |data| data[:benchmark_code]}
    ap vars
    puts "Number of variables #{vars.length} unique #{vars.values.uniq.length}"
  end

  def self.symbol(stub, period, fuel_type, datatype, percent_type = nil)
    [stub, period_name(period), fuel_type, datatype, percent_type].compact.map(&:to_s).join('_').to_sym
  end

  def self.calc_template_variable(stub, period, fuel_type, datatype, benchmark_code_prefix, percent_type = nil)
    {
      self.symbol(stub, period, fuel_type, datatype, percent_type) => {
        description:    "#{period_name(period)} #{fuel_type} in #{datatype}",
        units:          percent_type || datatype,
        benchmark_code: benchmark_code(benchmark_code_prefix, period, fuel_type, datatype, percent_type)
      }
    }
  end

  def self.percent_code(period)
    # 2 different percent comparison : year v. year, year v. activationyear
    period.keys[0] == :year ? 'y' : 'a'
  end

  def self.benchmark_code(prefix, period, fuel_type, datatype, percent_type = nil)
    dt = ChangeInEnergyUseSymbols::DATA_TYPES[datatype]
    p = percent_type.nil? ? '' : 'p'
    ft = fuel_type == :energy ? 'x' : ChangeInEnergyUseSymbols::METER_TYPES[fuel_type]
    prefix + dt + ft + period_code(period) + p
  end

  def self.period_code(period)
    case period
    when {year: 0}
      '0'
    when {year: -1}
      'n'
    when {activationyear: 0}
      'a'
    else
      raise EnergySparksUnsupportedFunctionalityException, "period of #{period}"
    end
  end

  def self.period_name(period)
    return nil if period.nil?
    return 'activationyear' if period.keys[0] == :activationyear
    period_number = period.values[0]
    raise EnergySparksUnsupportedFunctionalityException, "period number not 0 or -1 = #{period_number}" unless period_number.between?(-1,0)

    (period_number == 0 ? 'current' : 'previous') + '_' + period.keys[0].to_s
  end
  # variables and benchmark codes generated by above classes, list generated by calling self.print_benchmark_codes
=begin
                                :current_year_electricity_kwh => "ke0",
                               :previous_year_electricity_kwh => "ken",
              :previous_year_electricity_kwh_relative_percent => "kenp",
                                        :current_year_gas_kwh => "kg0",
                                       :previous_year_gas_kwh => "kgn",
                      :previous_year_gas_kwh_relative_percent => "kgnp",
                            :current_year_storage_heaters_kwh => "kh0",
                           :previous_year_storage_heaters_kwh => "khn",
          :previous_year_storage_heaters_kwh_relative_percent => "khnp",
                                   :current_year_solar_pv_kwh => "ks0",
                                  :previous_year_solar_pv_kwh => "ksn",
                 :previous_year_solar_pv_kwh_relative_percent => "ksnp",
                                     :current_year_energy_kwh => "kx0",
                                    :previous_year_energy_kwh => "kxn",
                   :previous_year_energy_kwh_relative_percent => "kxnp",
                                :current_year_electricity_co2 => "ce0",
                               :previous_year_electricity_co2 => "cen",
              :previous_year_electricity_co2_relative_percent => "cenp",
                                        :current_year_gas_co2 => "cg0",
                                       :previous_year_gas_co2 => "cgn",
                      :previous_year_gas_co2_relative_percent => "cgnp",
                            :current_year_storage_heaters_co2 => "ch0",
                           :previous_year_storage_heaters_co2 => "chn",
          :previous_year_storage_heaters_co2_relative_percent => "chnp",
                                   :current_year_solar_pv_co2 => "cs0",
                                  :previous_year_solar_pv_co2 => "csn",
                 :previous_year_solar_pv_co2_relative_percent => "csnp",
                                     :current_year_energy_co2 => "cx0",
                                    :previous_year_energy_co2 => "cxn",
                   :previous_year_energy_co2_relative_percent => "cxnp",
                           :"current_year_electricity_\u00A3" => "pe0",
                          :"previous_year_electricity_\u00A3" => "pen",
         :"previous_year_electricity_\u00A3_relative_percent" => "penp",
                                   :"current_year_gas_\u00A3" => "pg0",
                                  :"previous_year_gas_\u00A3" => "pgn",
                 :"previous_year_gas_\u00A3_relative_percent" => "pgnp",
                       :"current_year_storage_heaters_\u00A3" => "ph0",
                      :"previous_year_storage_heaters_\u00A3" => "phn",
     :"previous_year_storage_heaters_\u00A3_relative_percent" => "phnp",
                              :"current_year_solar_pv_\u00A3" => "ps0",
                             :"previous_year_solar_pv_\u00A3" => "psn",
            :"previous_year_solar_pv_\u00A3_relative_percent" => "psnp",
                                :"current_year_energy_\u00A3" => "px0",
                               :"previous_year_energy_\u00A3" => "pxn",
              :"previous_year_energy_\u00A3_relative_percent" => "pxnp",
                              :activationyear_electricity_kwh => "kea",
             :activationyear_electricity_kwh_relative_percent => "keap",
                                      :activationyear_gas_kwh => "kga",
                     :activationyear_gas_kwh_relative_percent => "kgap",
                          :activationyear_storage_heaters_kwh => "kha",
         :activationyear_storage_heaters_kwh_relative_percent => "khap",
                                 :activationyear_solar_pv_kwh => "ksa",
                :activationyear_solar_pv_kwh_relative_percent => "ksap",
                                   :activationyear_energy_kwh => "kxa",
                  :activationyear_energy_kwh_relative_percent => "kxap",
                              :activationyear_electricity_co2 => "cea",
             :activationyear_electricity_co2_relative_percent => "ceap",
                                      :activationyear_gas_co2 => "cga",
                     :activationyear_gas_co2_relative_percent => "cgap",
                          :activationyear_storage_heaters_co2 => "cha",
         :activationyear_storage_heaters_co2_relative_percent => "chap",
                                 :activationyear_solar_pv_co2 => "csa",
                :activationyear_solar_pv_co2_relative_percent => "csap",
                                   :activationyear_energy_co2 => "cxa",
                  :activationyear_energy_co2_relative_percent => "cxap",
                         :"activationyear_electricity_\u00A3" => "pea",
        :"activationyear_electricity_\u00A3_relative_percent" => "peap",
                                 :"activationyear_gas_\u00A3" => "pga",
                :"activationyear_gas_\u00A3_relative_percent" => "pgap",
                     :"activationyear_storage_heaters_\u00A3" => "pha",
    :"activationyear_storage_heaters_\u00A3_relative_percent" => "phap",
                            :"activationyear_solar_pv_\u00A3" => "psa",
           :"activationyear_solar_pv_\u00A3_relative_percent" => "psap",
                              :"activationyear_energy_\u00A3" => "pxa",
             :"activationyear_energy_\u00A3_relative_percent" => "pxap"
=end
end
