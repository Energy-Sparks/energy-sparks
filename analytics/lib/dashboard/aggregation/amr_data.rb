require_relative '../utilities/half_hourly_data'
require_relative '../utilities/half_hourly_loader'
require_relative '../../../app/services/baseload/baseload_calculator'
require_relative '../../../app/services/baseload/statistical_baseload_calculator'
require_relative '../../../app/services/baseload/overnight_baseload_calculator'

# Timed data from a meter
# references consumption data, costs and carbon emissions
class AMRData < HalfHourlyData
  # usage * consumption costs
  attr_reader :economic_tariff
  # usage * consumption costs * usage -
  #   added since energy prices went up in the 2022 energy crisis to help predict increased costs
  attr_reader :current_economic_tariff
  # usage * consumption charge and standing charges, VAT, and other fixed charges
  attr_reader :accounting_tariff
  attr_reader :carbon_emissions
  attr_accessor :open_close_breakdown

  class UnexpectedDataType < StandardError; end

  def initialize(type)
    super
    @total = {}
  end

  def self.copy_amr_data(original_amr_data, sd = original_amr_data.start_date, ed = original_amr_data.end_date)
    new_amr_data = AMRData.new(original_amr_data.type)
    (sd..ed).each do |date|
      new_amr_data.add(date, original_amr_data.clone_one_days_data(date))
    end
    new_amr_data
  end

  def set_post_aggregation_state
    @carbon_emissions.post_aggregation_state        = true if @carbon_emissions.is_a?(CarbonEmissionsParameterised)
    @economic_tariff.post_aggregation_state         = true if @economic_tariff.is_a?(CachingEconomicCosts)
    if @current_economic_tariff.is_a?(CachingCurrentEconomicCosts)
      @current_economic_tariff.post_aggregation_state = true
    end
    @accounting_tariff.post_aggregation_state = true if @accounting_tariff.is_a?(CachingAccountingCosts)
  end

  def set_economic_tariff_schedule(tariff)
    @economic_tariff = tariff
  end

  def set_current_economic_tariff_schedule(tariff)
    logger.info 'Setting current economic cost schedule'
    @current_economic_tariff = tariff
  end

  def set_current_economic_tariff_schedule_to_economic_tariff
    logger.info 'Setting current economic cost schedule to existing economic cost schedule'
    @current_economic_tariff = @economic_tariff
  end

  def set_accounting_tariff_schedule(tariff)
    @accounting_tariff = tariff
  end

  def set_carbon_schedule(co2)
    @carbon_emissions = co2
  end

  # Called from aggregation_mixin, SyntheticMeter and TargetMeter
  def set_carbon_emissions(meter_id_for_debug, flat_rate, grid_carbon)
    @carbon_emissions = CarbonEmissionsParameterised.create_carbon_emissions(meter_id_for_debug, self, flat_rate,
                                                                             grid_carbon)
  end

  def add(date, one_days_data)
    raise EnergySparksUnexpectedStateException.new('AMR Data must not be nil') if one_days_data.nil?
    unless one_days_data.is_a?(OneDayAMRReading)
      raise EnergySparksUnexpectedStateException.new("AMR Data now held as OneDayAMRReading not #{one_days_data.class.name}")
    end
    if date != one_days_data.date
      raise EnergySparksUnexpectedStateException.new("AMR Data date mismatch not #{date} v. #{one_days_data.date}")
    end

    set_min_max_date(date)

    self[date] = one_days_data

    @total = {}
    @cache_days_totals.delete(date)
  end

  # warning doesn't set start_date, end_date
  def delete(date)
    @cache_days_totals.delete(date)
    super
  end

  # warning doesn't set start_date, end_date
  def delete_date_range(d1, d2)
    (d1..d2).map do |date|
      delete(date)
    end
  end

  def data(date, halfhour_index)
    raise EnergySparksUnexpectedStateException.new('Deprecated call to amr_data.data()')
  end

  # called from base class histogram function
  def one_days_data_x48(date)
    days_kwh_x48(date)
  end

  def days_kwh_x48(date, type = :kwh, community_use: nil)
    check_type(type)

    return open_close_breakdown.days_kwh_x48(date, type, community_use: community_use) unless community_use.nil?

    kwhs = self[date].kwh_data_x48
    return kwhs if type == :kwh
    return @economic_tariff.days_cost_data_x48(date) if %i[£ economic_cost].include?(type)
    return @current_economic_tariff.days_cost_data_x48(date) if %i[£current current_economic_cost].include?(type)
    return @accounting_tariff.days_cost_data_x48(date) if type == :accounting_cost

    co2_x48(date) if type == :co2
  end

  private def co2_x48(date)
    return @carbon_emissions.one_days_data_x48(date) unless @type == :solar_pv

    @solar_pv_co2_x48_cache ||= {}
    @solar_pv_co2_x48_cache[date] ||= calculate_solar_pv_co2_x48(date)
    @solar_pv_co2_x48_cache[date]
  end

  # performance benefit in collatin the information
  private def calculate_information_date_range_deprecated(start_date, end_date)
    kwh = kwh_date_range(start_date, end_date, :kwh)
    £   = kwh_date_range(start_date, end_date, :£)
    co2 = kwh_date_range(start_date, end_date, :co2)

    {
      kwh: kwh,
      co2: co2,
      £: £,
      co2_intensity_kw_per_kwh: co2 / kwh,
      blended_£_per_kwh: £ / kwh
    }
  end

  def information_date_range_deprecated(start_date, end_date)
    @cached_information ||= {}
    @cached_information[start_date..end_date] ||= calculate_information_date_range_deprecated(start_date, end_date)
  end

  def blended_£_per_kwh_date_range(start_date, end_date)
    @blended_£_per_kwh_date_range ||= {}
    @blended_£_per_kwh_date_range[start_date..end_date] ||= calculate_blended_£_per_kwh_date_range(start_date, end_date)
  end

  def blended_rate(from_unit, to_unit, sd = up_to_1_year_ago, ed = end_date)
    @blended_rate ||= {}
    key         = [from_unit, to_unit,   sd, ed]
    reverse_key = [to_unit,   from_unit, sd, ed]
    return @blended_rate[key]               if @blended_rate.key?(key)
    return 1.0 / @blended_rate[reverse_key] if @blended_rate.key?(reverse_key)

    @blended_rate[key] ||= calculate_blended_rate(from_unit, to_unit, sd, ed)
  end

  private def calculate_blended_rate(from_unit, to_unit, sd, ed)
    from_value = kwh_date_range(sd, ed, from_unit)
    to_value   = kwh_date_range(sd, ed, to_unit)
    to_value / from_value
  end

  private def calculate_blended_£_per_kwh_date_range(sd, ed, datatype = :£)
    blended_rate(:kwh, datatype, sd, ed)
  end

  # calculates a blended rate x 48, based on aggregate data
  # which could either be parameterised costs or pre-calculated
  def blended_rate_£_per_kwh_x48(date, datatype = :£)
    kwh_x48 = days_kwh_x48(date)
    £_x48 = days_kwh_x48(date, datatype)
    AMRData.fast_divide_x48_by_x48(£_x48, kwh_x48)
  end

  def current_tariff_rate_£_per_kwh
    # needs to average rate over up to last year because:
    # - the latest day might have 0 kWh, and therefore £0 so no implied rate
    # - for electricity with differential tariffs this is a blended rate - beware
    @current_tariff_rate_£_per_kwh ||= calculate_blended_£_per_kwh_date_range(up_to_1_year_ago, end_date, :£current)
  end

  def historic_tariff_rate_£_per_kwh
    # needs to average rate over up to last year because:
    # - the latest day might have 0 kWh, and therefore £0 so no implied rate
    # - for electricity with differential tariffs this is a blended rate - beware
    @historic_tariff_rate_£_per_kwh ||= calculate_blended_£_per_kwh_date_range(up_to_1_year_ago, end_date, :£)
  end

  def calculate_solar_pv_co2_x48(date)
    co2_x48 = @carbon_emissions.one_days_data_x48(date)
    num_positive = co2_x48.count? { |c| c >= 0.0 }
    if num_positive > 44 # arbitrary mainly +tve
      fast_multiply_x48_x_scalar(co2_x48, -1.0)
    else
      co2_x48
    end
  end

  def date_exists_by_type?(date, type)
    check_type(type)
    case type
    when :kwh
      date_exists?(date)
    when :economic_cost, :£
      @economic_tariff.date_exists?(date)
    when :current_economic_cost, :£current
      @current_economic_tariff.date_exists?(date)
    when :accounting_cost
      @accounting_tariff.date_exists?(date)
    when :co2
      @carbon_emissions.date_exists?(date)
    end
  end

  def check_type(type)
    raise UnexpectedDataType, "Unexpected data type #{type}" unless %i[kwh £ economic_cost co2 £current
                                                                       current_economic_cost accounting_cost].include?(type)
  end

  def substitution_type(date)
    self[date].type
  end

  def substitution_date(date)
    self[date].substitute_date
  end

  def meter_id(date)
    self[date].meter_id
  end

  def days_amr_data(date)
    self[date]
  end

  def self.one_day_zero_kwh_x48
    single_value_kwh_x48(0.0)
  end

  def self.single_value_kwh_x48(kwh)
    Array.new(48, kwh)
  end

  def self.fast_multiply_x48_x_x48(a, b)
    c = one_day_zero_kwh_x48
    (0..47).each { |x| c[x] = a[x] * b[x] }
    c
  end

  def self.fast_divide_x48_by_x48(a, b)
    c = one_day_zero_kwh_x48
    (0..47).each { |x| c[x] = b[x] == 0.0 ? 0.0 : (a[x] / b[x]) }
    c
  end

  def self.fast_add_x48_x_x48(a, b)
    c = one_day_zero_kwh_x48
    (0..47).each { |x| c[x] = a[x] + b[x] }
    c
  end

  def self.fast_add_multiple_x48_x_x48(list)
    return list.first if list.length == 1

    c = one_day_zero_kwh_x48
    list.each do |data_x48|
      c = fast_add_x48_x_x48(c, data_x48)
    end
    c
  end

  def self.fast_average_multiple_x48(kwhs_x48)
    total = AMRData.fast_add_multiple_x48_x_x48(kwhs_x48)
    AMRData.fast_multiply_x48_x_scalar(total, 1.0 / kwhs_x48.length)
  end

  def self.fast_multiply_x48_x_scalar(a, scalar)
    a.map { |v| v * scalar }
  end

  def set_days_kwh_x48(date, days_kwh_data_x48)
    self[date].set_days_kwh_x48(days_kwh_data_x48)
  end

  def scale_kwh(scale_factor, date1: start_date, date2: end_date)
    (date1..date2).each do |date|
      add(date, OneDayAMRReading.scale(self[date], scale_factor)) if date_exists?(date)
    end
  end

  def kwh(date, halfhour_index, type = :kwh, community_use: nil)
    check_type(type)

    return open_close_breakdown.kwh(date, halfhour_index, type, community_use: community_use) unless community_use.nil?

    return self[date].kwh_halfhour(halfhour_index) if type == :kwh
    return @economic_tariff.cost_data_halfhour(date, halfhour_index) if %i[£ economic_cost].include?(type)

    if %i[£current
          current_economic_cost].include?(type)
      return @current_economic_tariff.cost_data_halfhour(date,
                                                         halfhour_index)
    end
    return @accounting_tariff.cost_data_halfhour(date, halfhour_index) if type == :accounting_cost

    co2_half_hour(date, halfhour_index) if type == :co2
  end

  private def co2_half_hour(date, halfhour_index)
    co2 = @carbon_emissions.co2_data_halfhour(date, halfhour_index)
    return -1 * co2.magnitude if @type == :solar_pv

    co2
  end

  def kw(date, halfhour_index)
    kwh(date, halfhour_index) * 2.0
  end

  def set_kwh(date, halfhour_index, kwh)
    self[date].set_kwh_halfhour(halfhour_index, kwh)
  end

  def add_to_kwh(date, halfhour_index, kwh)
    self[date].set_kwh_halfhour(halfhour_index, kwh + kwh(date, halfhour_index))
  end

  def one_day_kwh(date, type = :kwh, community_use: nil)
    check_type(type)

    return open_close_breakdown.one_day_kwh(date, type, community_use: community_use) unless community_use.nil?

    return self[date].one_day_kwh if type == :kwh
    return @economic_tariff.one_day_total_cost(date) if %i[£ economic_cost].include?(type)
    return @current_economic_tariff.one_day_total_cost(date) if %i[£current current_economic_cost].include?(type)
    return @accounting_tariff.one_day_total_cost(date) if type == :accounting_cost

    co2_one_day(date) if type == :co2
  end

  def check_for_bad_values(sd: start_date, ed: end_date, type: :kwh)
    problems = { missing: [], nan: [], infinite: [], nil: [] }

    (sd..ed).each do |date|
      if date_exists?(date)
        v = one_day_kwh(date, type)
        if v.nil?
          problems[:nil].push(date)
        elsif v.nan?
          problems[:nan].push(date)
        elsif v.infinite?
          problems[:infinite].push(date)
        end
      else
        problems[:missing].push(date)
      end
    end
    problems
  end

  private def co2_one_day(date)
    co2 = @carbon_emissions.one_day_total(date)
    return -1 * co2.magnitude if @type == :solar_pv

    co2
  end

  def clone_one_days_data(date)
    self[date].deep_dup
  end

  # called from inherited half_hourly)data.one_day_total(date), shouldn't use generally
  def one_day_total(date, type = :kwh)
    check_type(type)
    one_day_kwh(date, type)
  end

  def total(type = :kwh)
    check_type(type)
    @total[type] ||= calculate_total(type)
  end

  def calculate_total(type)
    check_type(type)
    t = 0.0
    (start_date..end_date).each do |date|
      t += one_day_kwh(date, type)
    end
    t
  end

  def kwh_date_range(date1, date2, type = :kwh, community_use: nil)
    check_type(type)

    unless community_use.nil?
      return open_close_breakdown.kwh_date_range(date1, date2, type,
                                                 community_use: community_use)
    end

    return one_day_kwh(date1, type) if date1 == date2

    total_kwh = 0.0
    (date1..date2).each do |date|
      total_kwh += one_day_kwh(date, type)
    end
    total_kwh
  end

  def economics_date_range(date1, date2, community_use: nil)
    kwh = kwh_date_range(date1, date2, :kwh, community_use: community_use)
    £ = kwh_date_range(date1, date2, :£, community_use: community_use)
    {
      kwh: kwh,
      £: £,
      rate: kwh == 0.0 ? current_tariff_rate_£_per_kwh : £ / kwh # risk this may end up being infinity
    }
  end

  def kwh_period(period)
    kwh_date_range(period.start_date, period.end_date)
  end

  def average_in_date_range(date1, date2, type = :kwh)
    check_type(type)
    kwh_date_range(date1, date2, type) / (date2 - date1 + 1)
  end

  def average_in_date_range_ignore_missing(date1, date2, type = :kwh)
    check_type(type)
    kwhs = []
    (date1..date2).each do |date|
      kwhs.push(one_day_kwh(date, type)) if date_exists?(date)
    end
    kwhs.empty? ? 0.0 : (kwhs.inject(:+) / kwhs.length)
  end

  def kwh_date_list(dates, type = :kwh)
    check_type(type)
    total_kwh = 0.0
    dates.each do |date|
      total_kwh += one_day_kwh(date, type)
    end
    total_kwh
  end

  def overnight_baseload_kw(date, data_type = :kwh)
    # use calculator thats looks at overnight period
    baseload_calculator(true).baseload_kw(date, data_type)
  end

  def average_overnight_baseload_kw_date_range(date1 = start_date, date2 = end_date)
    # use calculator thats specifically looks at overnight period
    baseload_calculator(true).average_overnight_baseload_kw_date_range(date1, date2)
  end

  def statistical_baseload_kw(date, data_type = :kwh)
    # use statistical calculator
    baseload_calculator(false).baseload_kw(date, data_type)
  end

  def statistical_peak_kw(date)
    highest_sorted_kwh = days_kwh_x48(date).sort.last(3)
    average_kwh = highest_sorted_kwh.sum.to_f / highest_sorted_kwh.size
    average_kwh * 2.0 # convert to kW
  end

  def peak_kw_kwh_date_range(date1, date2)
    total = 0.0
    (date1..date2).each do |date|
      total += peak_kw(date)
    end
    total
  end

  def peak_kw(date)
    days_kwh_x48(date).max * 2.0 # 2.0 = half hour kWh to kW
  end

  def peak_kw_date_range_with_dates(date1 = start_date, date2 = end_date, top_n = 1)
    peaks_by_day = peak_kws_date_range(date1, date2)
    reverse_sorted_peaks = peaks_by_day.sort_by { |_date, kw| -kw }
    return reverse_sorted_peaks if top_n.nil?

    Hash[reverse_sorted_peaks[0...top_n]]
  end

  def peak_kws_date_range(date1 = start_date, date2 = end_date)
    daily_peaks = {}
    (date1..date2).each do |date|
      daily_peaks[date] = peak_kw(date)
    end
    daily_peaks
  end

  def up_to_1_year_ago
    [end_date - 365, start_date].max
  end

  def economic_cost_for_x48_kwhs(date, kwh_x48)
    rate_£_per_kwh_x48 = blended_rate_£_per_kwh_x48(date)
    res = AMRData.fast_multiply_x48_x_x48(kwh_x48, rate_£_per_kwh_x48)
    res.sum
  end

  def self.create_empty_dataset(type, start_date, end_date, reading_type = 'ORIG')
    data = AMRData.new(type)
    (start_date..end_date).each do |date|
      data.add(date, OneDayAMRReading.new('Unknown', date, reading_type, nil, DateTime.now, one_day_zero_kwh_x48))
    end
    data
  end

  def summarise_bad_data
    date, one_days_data = first
    logger.info '=' * 80
    logger.info "Bad data for meter #{one_days_data.meter_id}"
    logger.info "Valid data between #{start_date} and #{end_date}"
    key, _value = first
    logger.info "Ignored data between #{key} and #{start_date} - because of long gaps" if key < start_date
    bad_data_stats = bad_data_count
    percent_bad = 100.0
    percent_bad = (100.0 * (length - bad_data_count['ORIG'].length) / length).round(1) if bad_data_count.key?('ORIG')
    logger.info "bad data summary: #{percent_bad}% substituted"
    bad_data_count.each do |type, dates|
      type_description = format('%-60.60s', OneDayAMRReading.amr_types[type][:name])
      logger.info " #{type}: #{type_description} * #{dates.length}"
      if type != 'ORIG'
        cpdp = CompactDatePrint.new(dates)
        cpdp.log
      end
    end
    bad_dates = dates_with_non_finite_values
    logger.info "bad non finite data on these dates: #{bad_dates.join(';')}" unless bad_dates.empty?
  end

  def summarise_bad_data_stdout
    date, one_days_data = first
    puts '=' * 80
    puts "Bad data for meter #{one_days_data.meter_id}"
    puts "Valid data between #{start_date} and #{end_date}"
    key, _value = first
    puts "Ignored data between #{key} and #{start_date} - because of long gaps" if key < start_date
    bad_data_stats = bad_data_count
    percent_bad = 100.0
    percent_bad = (100.0 * (length - bad_data_count['ORIG'].length) / length).round(1) if bad_data_count.key?('ORIG')
    puts "bad data summary: #{percent_bad}% substituted"
    bad_data_count.each do |type, dates|
      type_description = format('%-60.60s', OneDayAMRReading.amr_types[type][:name])
      puts " #{type}: #{type_description} * #{dates.length}"
      if type != 'ORIG'
        cpdp = CompactDatePrint.new(dates)
        cpdp.print
      end
    end
    bad_dates = dates_with_non_finite_values
    puts "bad non finite data on these dates: #{bad_dates.join(';')}" unless bad_dates.empty?
  end

  def dates_with_non_finite_values(sd = start_date, ed = end_date)
    list = []
    (sd..ed).each do |date|
      next if date_missing?(date)

      list.push(date) if days_kwh_x48(date).any? { |kwh| kwh.nil? || !kwh.finite? }
    end
    list
  end

  # take one set (dd_data) of half hourly data from self
  # - avoiding performance hit of taking a copy
  # caller expected to ensure start and end dates reasonable
  def minus_self(dd_data, min_value = nil)
    sd = start_date > dd_data.start_date ? start_date : dd_data.start_date
    ed = end_date < dd_data.end_date ? end_date : dd_data.end_date
    (sd..ed).each do |date|
      (0..47).each do |halfhour_index|
        updated_kwh = kwh(date, halfhour_index) - dd_data.kwh(date, halfhour_index)
        if min_value.nil?
          set_kwh(date, halfhour_index, updated_kwh)
        else
          set_kwh(date, halfhour_index, updated_kwh > min_value ? updated_kwh : min_value)
        end
      end
    end
  end

  private

  # go through amr_data creating 'histogram' of type of amr_data by type (original data v. substituted)
  # returns {type} = [list of dates of that type]
  def bad_data_count
    bad_data_type_count = {}
    (start_date..end_date).each do |date|
      one_days_data = self[date]
      bad_data_type_count[one_days_data.type] = [] unless bad_data_type_count.key?(one_days_data.type)
      bad_data_type_count[one_days_data.type].push(date)
    end
    bad_data_type_count
  end

  # Returns a baseload calculator. Parameter controls whether a statistical or overnight calculator is created. Pass
  # true for schools with solar pv
  def baseload_calculator(solar_pv)
    @calculators ||= {}
    @calculators[solar_pv] ||= Baseload::BaseloadCalculator.calculator_for(self, solar_pv)
  end
end
