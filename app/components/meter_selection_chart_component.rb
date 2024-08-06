# frozen_string_literal: true

# Builds a chart that has an additional select control for switching
# between meter specific views
#
# Supports majority of same parameters as ChartComponents except +html_class+ which is
# set to 'usage-chart'. This is used by selectors in usage_charts.js to drive the dynamic
# chart behaviour
#
# New parameters:
#
# chart_title_key: i18n key for chart title
# chart_subtitle_key i18n key for formatting dynamic subtitles as meter options are changed
# meters - list of meters to be displayed
# date_ranges_by_meter - hash of mpxn => { meter:, start_date:, end_date }
# used to build the sub titles for each meter
class MeterSelectionChartComponent < ViewComponent::Base
  include ChartHelper

  delegate :school, :meter_selection_options, :underlying_meters, to: :@meter_selection

  attr_reader :chart_type, :chart_title_key, :chart_options

  def initialize(chart_type:, meter_selection:, chart_title_key:, chart_subtitle_key:, **chart_options)
    @chart_type = chart_type
    @meter_selection = meter_selection
    @chart_title_key = chart_title_key
    @chart_subtitle_key = chart_subtitle_key
    @chart_options = chart_options.except(:html_class, :chart_config)
  end

  def configuration
    create_chart_config(school, @chart_type)
  end

  def chart_config
    create_chart_config(school, @chart_type, @meter_selection.meter_selection_options.first.mpan_mprn)
  end

  def chart_descriptions
    @meter_selection.date_ranges_by_meter.transform_values do |dates|
      I18n.t(@chart_subtitle_key,
             start_date: dates[:start_date].to_fs(:es_short),
             end_date: dates[:end_date].to_fs(:es_short),
             meter: dates[:meter]&.name_or_mpan_mprn)
    end
  end
end
