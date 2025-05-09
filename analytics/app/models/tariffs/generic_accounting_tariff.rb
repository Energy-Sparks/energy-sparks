class GenericAccountingTariff
  include Logging

  class OverlappingTimeRanges < StandardError; end
  class IncompleteTimeRanges < StandardError; end
  class TimeRangesNotOn30MinuteBoundary  < StandardError; end
  class UnexpectedRateType < StandardError; end

  MIN_DEFAULT_START_DATE = Date.new(2008, 1, 1)
  MAX_DEFAULT_END_DATE   = Date.new(2050, 1, 1)
  FLAT_RATE = 'flat_rate'.freeze

  attr_reader :tariff, :fuel_type

  def initialize(meter, tariff)
    @mpxn       = meter.mpxn
    @amr_data   = meter.amr_data
    @fuel_type  = meter.fuel_type
    @tariff     = tariff
    check_differential_times(all_times) if differential?
    remove_climate_change_levy_from_standing_charges
    default_missing_dates
  end

  def start_date
    @tariff[:start_date]
  end

  def end_date
    @tariff[:end_date]
  end

  def differential?
    @tariff[:type] == :differential
  end

  def flat_tariff?
    @tariff[:type] == :flat
  end

  def climate_change_levy?
    @climate_change_levy
  end

  #Treats site wide and school group tariffs as defaults
  #so school and meter specific tariffs are not defaults
  def default?
    defaulted_tariff?
  end

  def dcc?
    @tariff[:source] == :dcc
  end

  def system_wide?
    tariff[:system_wide] == true || tariff[:tariff_holder] == :site_settings
  end

  def backdate_tariff(start_date)
    @tariff[:start_date] = start_date
  end

  def in_date_range?(date)
    date >= @tariff[:start_date] && date <= @tariff[:end_date]
  end

  #Calculates use the "economic costs" for usage on a specific date
  #Applies the flat or differential rates but ignores all other charges
  def economic_costs(date, kwh_x48)
    OneDaysCostData.new(
      rates_x48: basic_costs(date, kwh_x48),
      differential: differential?,
      standing_charges: {},
      system_wide: system_wide?,
      default: default?,
      tariff: self
    )
  end

  #Calculate the full accounting costs for usage on a specific date
  def costs(date, kwh_x48)
    rates_x48 = basic_costs(date, kwh_x48)
    #add the additional cost components into the rates_x48 hash
    rates_x48.merge!(rate_per_kwh_standing_charges(kwh_x48))
    rates_x48.merge!(climate_change_level_costs(date, kwh_x48)) if climate_change_levy?
    rates_x48.merge!(duos_costs(date, kwh_x48)) if has_duos_charge?

    standing_charges = standing_charges(date, kwh_x48.sum)

    #add VAT to rates_x48 hash
    rates_x48.merge!(apply_vat(rates_x48, standing_charges)) if vat > 0.0

    OneDaysCostData.new(
      rates_x48: rates_x48,
      differential: differential?,
      standing_charges: standing_charges,
      system_wide: system_wide?,
      default: default?,
      tariff: self
    )
  end

  private

  # returns a hash, whereas other parent classes just return the value
  # because a single tier type might return a dffierent sub type for
  # each threshold, so 1 type in but potentially multiple types returned
  def weighted_costs(kwh_x48, type)
    if tiered_rate_type?(type)
      calculate_tiered_costs_x48(type, kwh_x48)
    else
      weights = DateTimeHelper.weighted_x48_vector_fast_inclusive(times(type), rate(type))
      cost_x48 = AMRData.fast_multiply_x48_x_x48(weights, kwh_x48)
      { differential_rate_name(type) => cost_x48 }
    end
  end

  # non per kWh standing charges
  def standing_charges(date, days_kwh)
    standing_charge = {}
    tariff[:rates].each do |standing_charge_type, rate|
      if tnuos_type?(standing_charge_type) && rate == true
        standing_charge[standing_charge_type] = tnuos_cost(date)
      elsif standard_standing_charge_type?(standing_charge_type) && rate[:per] != :kwh
        dr = daily_rate(date, rate[:per], rate[:rate], days_kwh, standing_charge_type)
        standing_charge[standing_charge_type] = dr unless dr.nil?
      end
    end
    standing_charge
  end

  # apply per kWh 'standing charges' per half hour
  def rate_per_kwh_standing_charges(kwh_x48)
    rates = tariff[:rates].select do |standing_charge_type, rate|
      !tnuos_type?(standing_charge_type) &&
      standard_standing_charge_type?(standing_charge_type) &&
      rate[:per] == :kwh
    end

    rates.map do |standing_charge_type, rate|
      [
        standing_charge_type.to_s.humanize,
        AMRData.fast_multiply_x48_x_scalar(kwh_x48, rate[:rate])
      ]
    end.to_h
  end

  def all_times
    rate_types.map { |rt| times(rt) }
  end

  def times(type)
    @tariff[:rates][type][:from]..@tariff[:rates][type][:to]
  end

  def rate(type)
    @tariff[:rates][type][:rate]
  end

  def availability_type?(type)
    %i[agreed_availability_charge excess_availability_charge].include?(type)
  end

  def tiered_rate_type?(type)
    type.to_s.match?(/^tiered_rate[0-9]$/)
  end

  def rate_type?(type)
    type == :flat_rate || rate_rate_type?(type) || tiered_rate_type?(type)
  end

  def duos_type?(type)
    type.to_s.match?(/^duos/)
  end

  def tnuos_type?(type)
    type == :tnuos
  end

  def standard_standing_charge_type?(type)
    !rate_type?(type) && !climate_change_levy_type?(type) && !duos_type?(type)
  end

  def agreed_supply_capacity_calculator
    @agreed_supply_capacity_calculator ||= AgreedSupplyCapacityCharge.new(@amr_data, @tariff)
  end

  def agreed_supply_capacity_daily_cost(date)
    agreed_supply_capacity_calculator.agreed_supply_capacity_daily_cost(date)
  end

  def excess_supply_capacity_daily_cost(date)
    agreed_supply_capacity_calculator.excess_supply_capacity_daily_cost(date)
  end

  def daily_rate(date, per, rate, days_kwh, type)
    case per
    when :day
      rate
    when :month
      rate / DateTimeHelper.days_in_month(date)
    when :quarter
      rate / DateTimeHelper.days_in_quarter(date)
    when :kva
      if type == :agreed_availability_charge
        agreed_supply_capacity_daily_cost(date)
      elsif type == :excess_availability_charge
        excess_supply_capacity_daily_cost(date)
      else # reactive charges - unknown as not provided by AMR meter feeds, and not passed through DCC yet (June2021)
        0.0
      end
    when :kwh
      raise UnexpectedRateType, 'Unexpected internal error: unit rate type kwh should be handled as x48 rather than scalar'
    else
      raise UnexpectedRateType, "Unexpected unit rate type for tariff #{per}"
    end
  end

  def basic_costs(date, kwh_x48)
    flat_rate = flat_tariff?
    if flat_rate
      {
        FLAT_RATE => AMRData.fast_multiply_x48_x_scalar(kwh_x48, tariff[:rates][:flat_rate][:rate])
      }
    else
      rate_types.map { |type| weighted_costs(kwh_x48, type)}.inject(:merge)
    end
  end

  def default_missing_dates
    @tariff[:start_date] = MIN_DEFAULT_START_DATE if !@tariff.key?(:start_date) || @tariff[:start_date].nil?
    @tariff[:end_date] = MAX_DEFAULT_END_DATE if !@tariff.key?(:end_date) || @tariff[:end_date].nil?
  end

  def defaulted_tariff?
    %i[site_settings school_group].include?(tariff[:tariff_holder])
  end

  def rate_types
    tariff[:rates].keys.select { |type| rate_type?(type) }
  end

  def flat_rate_type?(type)
    type == :flat_rate
  end

  def weekend_type?
    tariff.key?(:weekend)
  end

  def weekday_type?
    tariff.key?(:weekday)
  end

  def climate_change_levy_type?(type)
    type == :climate_change_levy
  end

  def rate_rate_type?(type)
    type.to_s.match?(/^rate[0-9]$/)
  end

  def has_duos_charge?
    tariff[:rates].keys.any?{ |type| duos_type?(type) }
  end

  def has_tnuos_charge?
    tariff[:rates].keys.any?{ |type| tnuos_type?(type) }
  end

  #TODO: vat is converted into a formatted string in front end, but it could be passed directly
  #as a number
  def vat
    if @tariff.key?(:vat) # required if manually entered, not if from dcc
      @tariff[:vat].to_s.to_f / 100.0
    else
      return 0.0
    end
  end

  def apply_vat(rates_vat_x48, standing_charges)
    # spread standing charge VAT across every half hour
    # so can see as one value in charts and tabular user presentation
    vat_x48 = AMRData.fast_add_x48_x_x48(rates_vat_x48(rates_vat_x48), standing_charge_daily_vat_x48(standing_charges))
    { vat_description.to_sym => vat_x48 }
  end

  def standing_charge_daily_vat_x48(standing_charges)
    vat_daily = standing_charges.values.sum * vat
    AMRData.single_value_kwh_x48(vat_daily / 48.0)
  end

  def rates_vat_x48(rates_vat_x48)
    rates_x48 = AMRData.fast_add_multiple_x48_x_x48(rates_vat_x48.values)
    AMRData.fast_multiply_x48_x_scalar(rates_x48, vat)
  end

  #reformats value from front end
  def vat_description
    "vat@#{(vat * 100).round(0)}%"
  end

  def duos_costs(date, kwh_x48)
    costs = DUOSCharges.kwhs_x48(@mpxn, date, kwh_x48)

    costs.map do |colour_key, kwh_x48|
      duos_key = "duos_#{colour_key.to_s}".to_sym
      # fallback to 0.0 if can't find key in the rates, e.g. if using DuoS fallback
      [
        duos_key,
        AMRData.fast_multiply_x48_x_scalar(kwh_x48, tariff[:rates][duos_key] || 0.0)
      ]
    end.to_h
  end

  def tnuos_calculator
    @tnuos_calculator ||= TNUOSCharges.new(@amr_data, @tariff)
  end

  def tnuos_cost(date)
    tnuos_calculator.cost(date, @mpxn)
  end

  def differential_rate_name(type)
    ttr = GenericAccountingTariff.format_time_range(@tariff[:rates][type])
    append_weekday_weekend(ttr)
  end

  def self.format_time_range(rate)
    "#{rate[:from]} to #{rate[:to]}".freeze
  end

  def append_weekday_weekend(name)
    name += ' (weekends)' if weekend_type?
    name += ' (weekdays)' if weekday_type?
    name
  end

  def remove_climate_change_levy_from_standing_charges
    if @tariff.key?(:climate_change_levy)
      @climate_change_levy = @tariff[:climate_change_levy]
      @tariff.delete(:climate_change_levy)
    else
      @climate_change_levy = false
    end
  end

  def climate_change_level_costs(date, kwh_x48)
    climate_change_levey_key, levy = ClimateChangeLevy.rate(@fuel_type, date)
    {
      climate_change_levey_key => AMRData.fast_multiply_x48_x_scalar(kwh_x48, levy)
    }
  end

  def calculate_tiered_costs_x48(type, kwh_x48)
    costs_x48 = {}

    from_hh_index = @tariff[:rates][type][:from].to_halfhour_index
    to_hh_index   = @tariff[:rates][type][:to].to_halfhour_index

    (from_hh_index..to_hh_index).each do |hh_index|
      rates = tiered_rate(kwh_x48[hh_index], @tariff[:rates][type])
      rates.each do |new_tier_name, cost|
        costs_x48[new_tier_name] ||= AMRData.one_day_zero_kwh_x48
        costs_x48[new_tier_name][hh_index] = cost
      end
    end

    costs_x48
  end

  # returns a hash with seperate key for each threhold bucket
  def tiered_rate(kwh, rate_config)
    tiers = rate_config.select { |type, _config| tiered_rate_sub_type?(type) }

    tiers.map do |tier_name, tier|
      # PH 8Apr2021 - there is an ambiguity on the boundary between 2 thresholds
      #             - which rate is take exactly on the boundary
      kwh_above_threshold_start = kwh - tier[:low_threshold]
      next if kwh_above_threshold_start <= 0.0
      threshold_range = tier[:high_threshold] - tier[:low_threshold]
      kwh_in_threshold = [kwh_above_threshold_start, threshold_range].min
      [
        tier_description(tier_name, tier[:low_threshold], tier[:high_threshold], rate_config),
        tier[:rate] * kwh_in_threshold
      ]
    end.compact.to_h
  end

  def tiered_rate_sub_type?(type)
    type.to_s.match?(/tier[0-9]/)
  end

  def tier_description(tier_name, low_threshold, high_threshold, rate_config)
    time_range = GenericAccountingTariff.format_time_range(rate_config)
    threshold_range = threshhold_range_description(tier_name, low_threshold, high_threshold)
    trtr = "#{time_range}: #{threshold_range}"
    append_weekday_weekend(trtr)
  end

  def threshhold_range_description(tier_name, low_threshold, high_threshold)
    if high_threshold.infinite?
      "above #{low_threshold.round(0)} kwh"
    elsif low_threshold.zero?
      "below #{high_threshold.round(0)} kwh"
    else
      "#{low_threshold.round(0)} to #{high_threshold.round(0)} kwh"
    end
  end

  def check_differential_times(time_ranges)
    check_time_ranges_on_30_minute_boundaries(time_ranges)
    check_complete_time_ranges(time_ranges)
    check_overlapping_time_ranges(time_ranges)
  end

  def check_complete_time_ranges(time_ranges)
    if count_rates_every_half_hour(time_ranges).any?{ |v| v == 0 }
      tr_debug = time_ranges_compact_summary(time_ranges)
      raise IncompleteTimeRanges, "Incomplete differential tariff time of day ranges #{@mpxn}:  #{tr_debug}"
    end
  end

  def check_time_ranges_on_30_minute_boundaries(time_ranges)
    time_of_days = [time_ranges.map(&:first), time_ranges.map(&:last)].flatten
    if time_of_days.any?{ |tod| !tod.on_30_minute_interval? }
      raise TimeRangesNotOn30MinuteBoundary, "Differential tariff time of day rates not on 30 minute interval #{@mpxn}"
    end
  end

  def check_overlapping_time_ranges(time_ranges)
    if count_rates_every_half_hour(time_ranges).any?{ |v| v > 1 }
      tr_debug = time_ranges_compact_summary(time_ranges)
      raise OverlappingTimeRanges, "Overlapping differential tariff time of day ranges #{@mpxn}:  #{tr_debug}"
    end
  end

  def count_rates_every_half_hour(time_ranges)
    @count_rates_every_half_hour ||= calculate_count_rates_every_half_hour(time_ranges)
  end

  # given multiple time ranges coering a day
  # returns x48 of count of overall time range coverage
  # e.g. 0 value = missing, 2+ = duplicate/overlap
  def calculate_count_rates_every_half_hour(time_ranges)
    tr_masks = time_ranges.map{ |tr| DateTimeHelper.weighted_x48_vector_fast_inclusive(tr, 1) }
    AMRData.fast_add_multiple_x48_x_x48(tr_masks)
  end

  def time_ranges_compact_summary(time_ranges)
    time_ranges.map(&:to_s).join(', ')
  end

end
