# some charts are created by combining multiple charts
# e.g. a chart compariing a school with benchmark and exemplar schools
#      is created by combining 3 charts 1 for each school
#      a school versus its target (school) combines 2 charts
# or   a chart compariing multiple time periods e.g. this year versus last year
class AggregatorMultiSchoolsPeriods < AggregatorBase
  class InternalErrorOnlyOneResultExpected < StandardError; end

  attr_reader :min_combined_school_date, :max_combined_school_date, :single_series_aggregators

  def initialize(school, chart_config, results)
    @single_series_aggregators = []
    super
  end

  def calculate
    determine_multi_school_chart_date_range # directly modifies chart_config

    res = run_charts_for_multiple_schools_and_time_periods(schools, periods)

    @results = selective_copy_of_first_results

    merge_charts

    res # TODO(PH, 1Apr2022) remove legacy refactor result return
  end

  def determine_multi_school_chart_date_range
    determine_multi_school_chart_date_range_private
  end

  def schools
    @schools ||= schools_list
  end

  def periods
    @periods ||= [chart_config.timescale].flatten
  end

  def final_results
    single_series_aggregators.last.results
  end

  def series_manager
    final_results.series_manager
  end

  private

  # copy 1 example result apart from bucketed_data and bucketed_data_count
  # so the final returned results default x and y axis configration from 1
  # chart where there are mutliple charts, results for different time periods or
  # schools, so for example for multiple time periods the 1st result's x-axis is used
  def selective_copy_of_first_results
    # the results are calculated in reverse order (legacy design)
    single_series_aggregators.last.results.bucketless_result_copy
  end

  def number_of_periods
    periods.uniq.compact.length
  end

  def number_of_schools
    schools.map(&:name).uniq.length
  end

  def merge_charts
    results.bucketed_data       = {}
    results.bucketed_data_count = {}

    if chart_config.month_comparison?
      merge_monthly_comparison_charts
    elsif single_series_aggregators.length > 1 || number_of_periods > 1
      merge_multiple_charts
    else
      if single_series_aggregators.length != 1
        raise InternalErrorOnlyOneResultExpected, "Number of results = #{single_series_aggregators.length}"
      end

      results.bucketed_data       = single_series_aggregators.first.results.bucketed_data
      results.bucketed_data_count = single_series_aggregators.first.results.bucketed_data_count
    end
  end

  def merge_monthly_comparison_charts
    raise EnergySparksBadChartSpecification, 'More than one school not supported' if number_of_schools > 1

    merged = Charts::MergeMonthlyComparisons.merge(valid_aggregators.map(&:results), number_of_periods)
    results.x_axis = merged[:x_axis]
    results.bucketed_data = merged[:bucketed_data]
    results.bucketed_data_count = merged[:bucketed_data_count]
  end

  def valid_aggregators
    single_series_aggregators.select { |agg| agg.results.valid? }
  end

  def unique_periods
    @unique_periods ||= valid_aggregators.map { |agg| agg.results.time_description }.uniq.length
  end

  def merge_multiple_charts
    valid_aggregators.each do |data|
      time_description = unique_periods <= 1 ? '' : (':' + data.results.time_description)
      school_name = schools.nil? || schools.length <= 1 || data.results.school_name.nil? ? '' : (':' + data.results.school_name)
      school_name = '' if number_of_schools <= 1 # TODO(PH, 9May2022) is schools.length <= 1 test in line above sufficient?

      data.results.bucketed_data.each do |series_name, x_data|
        new_series_name = series_name.to_s + time_description + school_name
        results.bucketed_data[new_series_name] = x_data
      end

      data.results.bucketed_data_count.each do |series_name, count_data|
        new_series_name = series_name.to_s + time_description + school_name
        results.bucketed_data_count[new_series_name] = count_data
      end
    end
  end

  def count_time_periods_and_school_names(bucketed_period_data)
    time_period_descriptions = {}
    school_names = {}
    bucketed_period_data.each do |period_data|
      bucketed_data, bucketed_data_count, time_description, school_name = period_data
      time_period_descriptions[time_description] = true
      school_names[school_name] = true
    end
    [time_period_descriptions.keys.length, school_names.keys.length]
  end

  def schools_list
    schools = [school]
    schools += benchmark_exemplar_schools_list if chart_config.include_benchmark?
    schools
  end

  def benchmark_exemplar_schools_list
    chart_config.benchmark_calculation_types.map do |calculation_type|
      school.benchmark_school(calculation_type)
    end
  end

  def determine_multi_school_chart_date_range_private
    extend_to_future = chart_config.include_target? && chart_config.extend_chart_into_future?

    logger.info '-' * 120
    logger.info "Determining maximum chart range for #{schools.length} schools:"

    min_date = schools.map do |school|
      Series::ManagerBase.new(school, chart_config).first_meter_date
    rescue EnergySparksNotEnoughDataException
      raise unless chart_config.ignore_single_series_failure?

      nil
    end.compact.max

    last_meter_dates = schools.map do |school|
      Series::ManagerBase.new(school, chart_config).last_meter_date
    rescue EnergySparksNotEnoughDataException
      raise unless chart_config.ignore_single_series_failure?

      nil
    end.compact

    max_date = extend_to_future ? last_meter_dates.max : last_meter_dates.min

    if extend_to_future && %i[up_to_a_year year].include?(chart_config.timescale)
      # special case for targeting and tracking charts
      min_date = [min_date, max_date - 364].min
    end

    chart_config.min_combined_school_date = @min_combined_school_date = min_date
    chart_config.max_combined_school_date = @max_combined_school_date = max_date

    description = schools.length > 1 ? 'Combined school charts' : 'School chart'
    logger.info description + " date range #{min_date} to #{max_date}"
    logger.info '-' * 120
  end

  def run_charts_for_multiple_schools_and_time_periods(schools, periods)
    schools.each do |school|
      # do it here so it maps to the 1st school
      temperature_adjustment_map(school)

      periods.reverse_each do |period| # do in reverse so final iteration represents the x-axis dates
        run_one_aggregation(period, school)
      rescue EnergySparksNotEnoughDataException
        raise unless chart_config.ignore_single_series_failure?
      end
    end
  end

  def run_one_aggregation(one_period, one_school)
    one_chart_config_hash = create_one_aggregation_chart_config(one_period, one_school)

    one_set_of_results = AggregatorResults.new

    ass = AggregatorSingleSeries.new(one_school, one_chart_config_hash, one_set_of_results)
    @single_series_aggregators.push(ass)

    ass.aggregate_period
  end

  def create_one_aggregation_chart_config(one_period, one_school)
    chartconfig_copy = chart_config.to_h.clone

    chartconfig_copy[:timescale] = one_period

    chartconfig_copy.merge!(chart_config.benchmark_override(one_school.name))

    chartconfig_copy
  end

  def temperature_adjustment_map(school)
    return unless chart_config.temperature_compensation_hash?

    chart_config.temperature_adjustment_map = temperature_compensation_temperature_map(school)
  end

  # for a chart_config e.g. :  {[ timescale: [ { schoolweek: 0 } , { schoolweek: -1 }, adjust_by_temperature:{ schoolweek: 0 } }
  # copy the corresponding temperatures from the :adjust_by_temperature onto all the corresponding :timescale periods
  # into a [date] => temperature hash
  # this allows in this example, for examples for all mondays to be compensated to the temperature of {schoolweek: 0}
  def temperature_compensation_temperature_map(school)
    unless chart_config.array_of_timescales?
      raise EnergySparksBadChartSpecification, 'Expected chart config timescale for array temperature compensation'
    end

    date_to_temperature_map = {}
    periods = chart_config.timescale
    chart_config_hash = chart_config.to_h
    periods.each do |period|
      chart_config_hash[:timescale] =
        date_to_temperature_map.empty? ? chart_config_hash[:adjust_by_temperature] : period
      series_manager = Series::ManagerBase.new(school, chart_config_hash)
      if date_to_temperature_map.empty?
        series_manager.periods[0].dates.each do |date|
          date_to_temperature_map[date] = school.temperatures.average_temperature(date)
        end
      else
        subsequent_period_dates = series_manager.periods[0].dates
        subsequent_period_dates.each_with_index do |date, index|
          date_to_temperature_map[date] = date_to_temperature_map.values[index]
        end
      end
    end

    date_to_temperature_map
  end

  def new_results_deprecated
    results = AggregatorResults.new
    results.bucketed_data = {}
    results.bucketed_data_count = {}
    results
  end
end
