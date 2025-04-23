require 'csv'

# 'base' class used for holding half hourly data typical to schools' energy analysis
# generally data held in derived classes e.g. temperatures, solar insolence, AMR data
# hash of date => 48 x float values
class HalfHourlyData < Hash
  include Logging
  alias parent_key? key?

  attr_reader :type, :validated

  def initialize(type)
    super()
    @min_date = Date.new(4000, 1, 1)
    @max_date = Date.new(1000, 1, 1)
    @validated = false
    @type = type
    @cache_days_totals = {} # speed optimisation cache[date] = total of 48x 1/2hour data
  end

  def add(date, half_hourly_data_x48)
    set_min_max_date(date)

    self[date] = half_hourly_data_x48

    data_count = validate_data(half_hourly_data_x48)

    @cache_days_totals.delete(date)

    return unless data_count != 48

    logger.debug "Missing data: #{date}: only #{data_count} of 48"
  end

  def remove_dates!(*dates)
    # Removes all key value pairs where the key matches a date in the 'dates' array
    dates.each { |date| delete(date) }

    reset_min_max_date
    self
  end

  def date_range
    start_date..end_date
  end

  def create_from_halfhourly_data(data)
    data.each do |date, half_hourly_data_x48|
      add(date, half_hourly_data_x48)
    end
  end

  def average(date)
    one_day_total(date) / 48.0
  end

  # returns an array, 1 greater in length than 'sorted_buckets',
  def histogram_half_hours_data(sorted_buckets, date1: start_date, date2: end_date)
    results = Array.new(sorted_buckets.length + 1, 0)
    (date1..date2).each do |date|
      one_days_data_x48(date).each do |d|
        i = sorted_buckets.bsearch_index { |h| h >= d } || sorted_buckets.length
        results[i] += 1
      end
    end
    results
  end

  def raw_data(date, halfhour_index)
    data(date, halfhour_index)
  end

  def days_valid_data
    end_date - start_date + 1
  end

  def average_in_date_range(start_date, end_date)
    if start_date < self.start_date || end_date > self.end_date
      return nil # NAN blows up write_xlsx
    end

    total = 0.0
    (start_date..end_date).each do |date|
      total += average(date)
    end
    total / (end_date - start_date + 1)
  end

  def date_missing?(date)
    !parent_key?(date)
  end

  def date_exists?(date)
    parent_key?(date)
  end

  def key?(date)
    # think better to avoid direct access to underlying Hash, to allow for future design changes
    # raise EnergySparksDeprecatedException.new('key?(date) deprecated for HalfHourlyData use date_missing?(date) instead')
    logger.warn "HalfHourlyData.key?() called on #{self.class.name} for date #{date}, is being deprecated in favour of date_missing?/date_exists?"
    logger.warn Thread.current.backtrace.join("\n")
    parent_key?(date)
  end

  def missing_dates
    dates = []
    (@min_date..@max_date).each do |date|
      dates << date if date_missing?(date)
    end
    dates
  end

  def validate_data(half_hourly_data_x48)
    half_hourly_data_x48.count { |val| val.is_a?(Float) || val.is_a?(Integer) }
  end

  # first and last dates maintained manually as the data is held in a hash for speed of access by date
  def set_min_max_date(date)
    @min_date = date if date < @min_date
    return unless date > @max_date

    @max_date = date
  end

  # half_hour_index is 0 to 47, i.e. the index for the half hour within the day
  def data(date, half_hour_index)
    self[date][half_hour_index]
  end

  def one_days_data_x48(date)
    self[date]
  end

  def one_day_total(date)
    unless @cache_days_totals.key?(date) # performance optimisation, needs rebenchmarking to check its an actual speedup
      if self[date].nil?
        logger.debug "Error: missing data for #{self.class.name} on date #{date} returning zero"
        return 0.0
      end
      total = self[date].sum # inject(:+)
      @cache_days_totals[date] = total
      return total
    end
    @cache_days_totals[date]
  end

  def total_in_period(start_date, end_date)
    total = 0.0
    (start_date..end_date).each do |date|
      total += one_day_total(date)
    end
    total
  end

  def start_date
    @min_date
  end

  def end_date
    @max_date
  end

  def set_start_date(date)
    return if date < @min_date

    logger.info "setting start date to #{date} truncating prior data"
    @min_date = date
    delete_if { |d, _value| d < date }
  end

  def set_end_date(date)
    return if date > @max_date

    logger.info "setting end date to #{date} truncating post data"
    @max_date = date
    delete_if { |d, _value| d > date }
  end

  def days
    (end_date - start_date + 1).to_i
  end

  def set_validated(valid)
    @validated = valid
  end

  # probably slow
  def all_dates
    keys.sort
  end

  # returns an array of DatePeriod - 1 for each acedemic years, with most recent year first
  def academic_years(holidays)
    logger.warn 'Warning: depricated from this location please use version in Class Holidays'
    holidays.academic_years(start_date, end_date)
  end

  def nearest_previous_saturday(date)
    date -= 1 while date.wday != 6
    date
  end

  def inspect
    "#{self.class.name} (days: #{keys.count}, object_id: #{format('0x00%x', (object_id << 1))})"
  end

  private

  def reset_min_max_date
    # This method needs to remain private as it should only ever be called by
    # the `remove_dates!` method
    @min_date, @max_date = keys.minmax
  end
end
