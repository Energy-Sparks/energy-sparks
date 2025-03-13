# frozen_string_literal: true

# Builds a chart that has an additional select control for switching
# between meter specific views
#
# Supports majority of same parameters as ChartComponents except +html_class+ which is
# set to 'usage-chart'. This is used by selectors in usage_charts.js to drive the dynamic
# chart behaviour required for these charts to work
#
# The chart_subtitle_key should refer to an HTML template that includes markup that allows start date, end
# date and meter name to be injected, e.g.:
#
# This is a subtitle for meter <span class="meter">%{meter}</span>
#  <span class="start-date">%{start_date}</span>-<span class="end-date">%{end_date}</span>
class MeterSelectionChartComponent < ViewComponent::Base
  renders_one :title
  renders_one :header
  renders_one :footer

  include ChartHelper

  delegate :school, :meter_selection_options, :underlying_meters, to: :@meter_selection

  attr_reader :chart_type, :chart_options

  # @param Symbol chart_type the name of the chart to display
  # @param Charts::MeterSelection meter_selection a meter selection instance that will be used to populate the
  # list of meters and build the dynamic sub titles that are displayed when meters are selected
  # @param String chart_subtitle_key the I18n key used to build the subtitles
  # @params chart_options all other ChartComponent options
  def initialize(chart_type:, meter_selection:, chart_subtitle_key:, **chart_options)
    @chart_type = chart_type
    @meter_selection = meter_selection
    @chart_subtitle_key = chart_subtitle_key
    @chart_options = chart_options.except(:html_class, :chart_config)
  end

  def render?
    @meter_selection.underlying_meters.any?
  end

  def configuration
    create_chart_config(school, @chart_type)
  end

  def chart_config
    create_chart_config(school, @chart_type, @meter_selection.meter_selection_options.first.mpan_mprn)
  end

  def chart_descriptions
    config = ChartManager.new(@meter_selection.meter_collection).get_chart_config(@chart_type)
    @meter_selection.date_ranges_by_meter.transform_values do |dates|
      I18n.t(@chart_subtitle_key,
             start_date: dates[:start_date].to_fs(:es_short),
             end_date: DateService.subtitle_end_date(config, dates[:end_date]).to_fs(:es_short),
             meter: dates[:meter]&.name_or_mpan_mprn)
    end
  end
end
