class AggregatorSingleSeries < AggregatorBase
  def aggregate_period # or school
    configure_series_manager

    configure_xaxis_buckets

    create_empty_bucket_series

    aggregate

    post_process_aggregation

    results.bucketed_data       = humanize_symbols(results.bucketed_data)
    results.bucketed_data_count = humanize_symbols(results.bucketed_data_count)
    results.time_description    = results.xbucketor.compact_date_range_description
    results.school_name         = school.name
    results.x_axis_date_ranges  = results.x_axis_bucket_date_ranges # TODO(PH,1Apr2022) rename from legacy refactor
  end

  private

  def date_filter
    @date_filter ||= Charts::Filters::DateFilter.new(school, chart_config, results)
  end

  def aggregate
    # loop through date groups on the x-axis; calculate aggregate data for each series in date range
    case chart_config[:x_axis]
    when :intraday
      start_date = results.series_manager.periods[0].start_date
      end_date = results.series_manager.periods[0].end_date
      aggregate_by_halfhour(start_date, end_date)
    when :datetime
      start_date = results.series_manager.periods[0].start_date
      end_date = results.series_manager.periods[0].end_date
      aggregate_by_datetime(start_date, end_date)
    else
      aggregate_by_day
    end
  end

  def configure_series_manager
    results.series_manager = Series::Multiple.new(school, chart_config)
    results.series_names = results.series_manager.series_bucket_names
    logger.info "Aggregating these series #{results.series_names} for #{school.name}"
    logger.info "aggregate_period Between #{results.series_manager.first_chart_date} and #{results.series_manager.last_chart_date}"
    if results.series_manager.periods.empty?
      raise "Error: not enough data available to create requested chart"
    end
  end

  def create_empty_bucket_series
    logger.debug "Creating empty data buckets #{results.series_names} x #{results.x_axis.length}"
    results.bucketed_data = {}
    results.bucketed_data_count = {}
    results.series_names.each do |series_name|
      results.bucketed_data[series_name] = Array.new(results.x_axis.length, nil)
      results.bucketed_data_count[series_name] = Array.new(results.x_axis.length, 0)
    end
  end

  def configure_xaxis_buckets
    results.xbucketor = XBucketBase.create_bucketor(chart_config[:x_axis], results.series_manager.periods)
    results.xbucketor.create_x_axis
    results.x_axis = results.xbucketor.x_axis
    results.x_axis_bucket_date_ranges = results.xbucketor.x_axis_bucket_date_ranges
    logger.debug "Breaking down into #{results.xbucketor.x_axis.length} X axis (date/time range) buckets"
    logger.debug "x_axis between #{results.xbucketor.data_start_date} and #{results.xbucketor.data_end_date} "
  end

  def post_process_aggregation
    create_trend_lines if results.series_manager.trendlines?
    results.scale_x_data(results.bucketed_data) unless chart_config.config_none_or_nil?(:yaxis_scaling)
  end

  def create_trend_lines
    tl = AggregatorTrendlines.new(school, chart_config, results)
    tl.create
  end

  # aggregate by whole date range, the 'series_manager' deals with any spliting within a day
  # e.g. 'school day in hours' v. 'school day out of hours'
  # returns a hash of this breakdown to the kWh values
  def aggregate_by_day
    count = 0
    if chart_config.add_daycount_to_legend? || chart_config.heating_daytype_filter?
      # this is slower, as it needs to loop through a day at a time
      # TODO(PH,17Jun2018) push down and optimise in series_data_manager
      results.xbucketor.x_axis_bucket_date_ranges.each do |date_range|
        x_index = results.xbucketor.index(date_range[0], nil)
        (date_range[0]..date_range[1]).each do |date|
          next unless date_filter.match_filter_by_day(date)
          multi_day_breakdown = results.series_manager.get_data([:daterange, [date, date]])
          multi_day_breakdown.each do |key, value|
            add_to_bucket(key, x_index, value)
            count += 1
          end
        end
      end
    else
      results.xbucketor.x_axis_bucket_date_ranges.each do |date_range|
        x_index = results.xbucketor.index(date_range[0], nil)
        multi_day_breakdown = results.series_manager.get_data([:daterange, date_range])
        unless multi_day_breakdown.nil? # added to support future targeted data past end of real meter date
          multi_day_breakdown.each do |key, value|
            add_to_bucket(key, x_index, value)
            count += 1
          end
        end
      end
    end
    logger.info "aggregate_by_day:  aggregated #{count} items"
  end

  def humanize_symbols(hash)
    if chart_config.series_breakdown == :daytype
      hash.transform_keys { |k| OpenCloseTime.humanize_symbol(k) }
    else
      hash
    end
  end

  def aggregate_by_halfhour(start_date, end_date)
    # Change Line Below 22Mar2019
    if results.bucketed_data.length == 1 && results.bucketed_data.keys[0] == Series::NoBreakdown::NONE
      aggregate_by_halfhour_simple_fast(start_date, end_date)
    else
      (start_date..end_date).each do |date|
        next if !date_filter.match_filter_by_day(date)
        (0..47).each do |halfhour_index|
          x_index = results.xbucketor.index(nil, halfhour_index)
          multi_day_breakdown = results.series_manager.get_data([:halfhour, date, halfhour_index])
          multi_day_breakdown.each do |key, value|
            add_to_bucket(key, x_index, value)
          end
        end
      end
    end
  end

  def aggregate_by_halfhour_simple_fast(start_date, end_date)
    total = Array.new(48, 0)
    count = 0
    (start_date..end_date).each do |date|
      next unless date_filter.match_filter_by_day(date)
      data = results.series_manager.get_one_days_data_x48(date, results.series_manager.kwh_cost_or_co2)
      total = AMRData.fast_add_x48_x_x48(total, data)
      count += 1
    end
    results.bucketed_data[Series::NoBreakdown::NONE] = total
    results.bucketed_data_count[Series::NoBreakdown::NONE] = Array.new(48, count)
  end

  def aggregate_by_datetime(start_date, end_date)
    (start_date..end_date).each do |date|
      next if !date_filter.match_filter_by_day(date)
      (0..47).each do |halfhour_index|
        x_index = results.xbucketor.index(date, halfhour_index)
        multi_day_breakdown = results.series_manager.get_data([:datetime, date, halfhour_index])
        multi_day_breakdown.each do |key, value|
          add_to_bucket(key, x_index, value)
        end
      end
    end
  end

  def add_to_bucket(series_name, x_index, value)
    logger.warn "Unknown series name #{series_name} not in #{results.bucketed_data.keys}" if !results.bucketed_data.key?(series_name)
    logger.warn "nil value for #{series_name}" if value.nil?

    return if value.nil?

    if results.bucketed_data[series_name][x_index].nil?
      results.bucketed_data[series_name][x_index] = value
    else
      results.bucketed_data[series_name][x_index] += value
    end

    count = 1
    if chart_config.add_daycount_to_legend?
      count = value != 0.0 ? 1 : 0
    end
    results.bucketed_data_count[series_name][x_index] += count # required to calculate kW
  end
end
