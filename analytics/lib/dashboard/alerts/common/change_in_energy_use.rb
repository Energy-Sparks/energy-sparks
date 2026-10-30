require_relative 'alert_analysis_base'
require_relative 'change_in_energy_use_symbols'

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
