class ChartInterpretation
  def initialize(chart_data)
    @chart_data = chart_data
  end

  def charts_completed
    series_name_count.empty? ? 0 : series_name_count.values[0]
  end

  def charts_requested
    @chart_data[:configuration][:timescale].is_a?(Array) ? @chart_data[:configuration][:timescale].length : 1
  end

  def start_date
    charts_completed == 1 ? @chart_data[:x_axis_ranges].first[0] : date_ranges_from_series_names.first[0]
  end

  def end_date
    charts_completed == 1 ? @chart_data[:x_axis_ranges].last[1] : date_ranges_from_series_names.last[1]
  end

  def days
    (end_date - start_date + 1).to_i
  end

  # series names are either 'holidays'or 'holidays:date-range'
  # prepended school name currently not supported
  private def series_name_count
    series_key_bases = @chart_data[:x_data].keys.map{ |composite_series_name| composite_series_name.split(':')[0] }
    stats = Hash.new{ |hash, key| hash[key] = 0 }
    series_key_bases.each do |name|
      stats[name] += 1
    end
    stats
  end

  private def date_ranges_from_series_names
    date_ranges_str = @chart_data[:x_data].keys.map{ |composite_series_name| composite_series_name.split(':')[1] }.uniq
    date_ranges = date_ranges_str.map { |date_range_str| date_range_str.split('-').map { |date_str| Date.parse(date_str) } }
    date_ranges.sort { |a,b| a[0] <=> b[0] }
  end
end