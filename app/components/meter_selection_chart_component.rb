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

  attr_reader :chart_type, :school, :meters, :date_ranges_by_meter, :chart_title_key, :chart_subtitle_key, :chart_options

  def initialize(chart_type:, school:, meters:, date_ranges_by_meter:, chart_title_key:, chart_subtitle_key:, **chart_options)
    @chart_type = chart_type
    @school = school
    @meters = meters
    @date_ranges_by_meter = date_ranges_by_meter
    @chart_title_key = chart_title_key
    @chart_subtitle_key = chart_subtitle_key
    @chart_options = chart_options.except(:html_class, :chart_config)
  end

  def configuration
    create_chart_config(@school, @chart_type)
  end

  def chart_config
    create_chart_config(school, chart_type, @meters.first.mpan_mprn)
  end

  def chart_descriptions
    @date_ranges_by_meter.to_h do |mpan_mprn, dates|
      [mpan_mprn, I18n.t(@chart_subtitle_key,
                         start_date: dates[:start_date].to_fs(:es_short),
                         end_date: dates[:end_date].to_fs(:es_short),
                         meter: dates[:meter]&.name_or_mpan_mprn || mpan_mprn)]
    end
  end

  def displayable_meters
    @meters.to_a.keep_if(&:has_readings?)
  end
end
