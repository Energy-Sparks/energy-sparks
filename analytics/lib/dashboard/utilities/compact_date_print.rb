# for debugging purposes log array of dates compactly:
# if range: 'date 1' to 'date 2'
# if single dates, in columns 'date 1' 'date 2'.......'date max_columns'
class CompactDatePrint
  include Logging

  def initialize(dates, columns = 2, date_format = '%a %d%b%y')
    @dates = dates
    @columns = columns
    @date_format = date_format
  end

  def log
    debug_output_dates(@dates)
  end

  def print
    print_output_dates(@dates)
  end

  private

  def debug_output_dates(dates, include_count: true, columns: @columns, separator: ' ', indent: '  ')
    return if dates.nil? || dates.empty?

    group_date_ranges(dates, include_count, columns, separator).each do |formatted_row|
      logger.debug indent + formatted_row
    end
  end

  def print_output_dates(dates, include_count: true, columns: @columns, separator: ' ', indent: '  ')
    return if dates.nil? || dates.empty?

    group_date_ranges(dates, include_count, columns, separator).each do |formatted_row|
      puts indent + formatted_row
    end
  end

  def group_date_ranges(dates, include_count, columns, separator)
    grouped_dates = summarise_date_ranges(dates)
    formatted_dates = grouped_dates.map { |dr| format_daterange(dr, include_count) }
    rows = formatted_dates.each_slice(columns).to_a
    rows.map { |r| r.join(separator) }
  end

  def summarise_date_ranges(dates)
    drs = dates.slice_when do |prev, curr|
      prev + 1 != curr
    end

    drs.map { |ds| ds.first..ds.last }
  end

  def format_daterange(date_range, include_count)
    between = ' to '
    count = format_include_count(date_range, include_count)

    if date_range.first == date_range.last
      fd = date_range.first.strftime(@date_format)
      fd.ljust(fd.length * 2 + between.length) + count
    else
      date_range.first.strftime(@date_format) + between + date_range.last.strftime(@date_format) + count
    end
  end

  def format_include_count(date_range, include_count)
    return '' unless include_count
    sprintf(' * %4d', date_range.last - date_range.first + 1)
  end
end
