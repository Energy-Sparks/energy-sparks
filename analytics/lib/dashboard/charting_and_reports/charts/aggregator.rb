# aggregator - aggregates energy data in a form which can be used for generating charts
#
#     x_axis:   primarily date based: bucketing by year, month, week, day, 1/2 hour, none (implies intraday 1/2 hour but not bucketed)
#     series:   stacked representation on Y axis: [school day in/out of hours, weekend holiday] || [gas, electric, storage, PV] || hotwater [useful/non-useful]
#     y_axis:   [kwh data from meters || derived CUSUM data || baseload || hot water type] potentially converted to another proportional metric e.g. £/pupil
#     y2_axis:  temperature or degree day data - averaged or calculated, not aggregated
#
# TODO(PH, 4Apr2022) - further refector required once proved in front end to make
#                      more direct access to AggregatorMultiSchoolsPeriods
class Aggregator
  include Logging

  attr_reader :bucketed_data, :total_of_unit, :x_axis, :y2_axis
  attr_reader :x_axis_bucket_date_ranges, :data_labels, :x_axis_label
  attr_reader :first_meter_date, :last_meter_date
  attr_reader :school

  def initialize(school, chart_config)
    @school = school
    @chart_config = chart_config
  end

  def valid?
    multi_school_period_aggregator.results.valid?
  end

  def initialise_schools_date_range
    multi_school_period_aggregator.determine_multi_school_chart_date_range

    [multi_school_period_aggregator.chart_config, multi_school_period_aggregator.schools]
  end

  def aggregate
    multi_school_period_aggregator.calculate
    unpack_results2(multi_school_period_aggregator.final_results)
    periods = multi_school_period_aggregator.periods
    schools = multi_school_period_aggregator.schools
    @chart_config[:min_combined_school_date] = multi_school_period_aggregator.min_combined_school_date
    @chart_config[:max_combined_school_date] = multi_school_period_aggregator.max_combined_school_date

    @bucketed_data        = multi_school_period_aggregator.results.bucketed_data
    @bucketed_data_count  = multi_school_period_aggregator.results.bucketed_data_count

    post_process = AggregatorPostProcess.new(multi_school_period_aggregator)
    post_process.calculate

    unpack_results2(post_process.results)

    @chart_config[:name] = dynamic_chart_name(multi_school_period_aggregator.series_manager)
  end

  def subtitle
    return nil unless @chart_config.key?(:subtitle)
    xbucketor = multi_school_period_aggregator.results.xbucketor
    if multi_school_period_aggregator.chart_config.daterange_subtitle? &&
       !xbucketor.data_start_date.nil? && !xbucketor.data_end_date.nil?
       start_date = xbucketor.data_start_date.strftime('%e %b %Y')
       end_date = xbucketor.data_end_date.strftime('%e %b %Y')
       I18n.t('analytics.aggregator.subttitle', start_date: start_date, end_date: end_date, default: nil) || "#{start_date} to #{end_date}"
    else
      'Internal error: expected subtitle request'
    end
  end

  def unpack_results2(res)
    @bucketed_data, @bucketed_data_count, @x_axis, @x_axis_bucket_date_ranges, @y2_axis, @series_manager, @series_names, @xbucketor, @data_labels, @x_axis_label, @chart_config[:y_axis_label], @last_meter_date = res.unpack2
    @first_meter_date = multi_school_period_aggregator.min_combined_school_date
    @last_meter_date = multi_school_period_aggregator.max_combined_school_date
  end

  def y2_axis?
    multi_school_period_aggregator.chart_config.y2_axis?
  end

  private

  def multi_school_period_aggregator
    @multi_school_period_aggregator ||= AggregatorMultiSchoolsPeriods.new(school, @chart_config, nil)
  end

  def dynamic_chart_name(series_manager)
    name = multi_school_period_aggregator.chart_config.name
    # make useful data available for binding
    meter         = [series_manager.meter].flatten.first
    second_meter  = [series_manager.meter].flatten.last
    total_kwh = multi_school_period_aggregator.results.bucketed_data.values.map{ |v| v.nil? ? 0.0 : v }.map(&:sum).sum.round(0) if name.include?('total_kwh') rescue 0.0

    ERB.new(name).result(binding)
  end
end
