module Comparisons
  class BaseloadPerPupilController < BaseController
    def index
      @results = Comparison::BaseloadPerPupil.where(school: @schools).where.not(one_year_baseload_per_pupil_kw: nil).order(one_year_baseload_per_pupil_kw: :desc)
      puts @results.count.inspect
      @chart = chart_configuration(@results)
    end

    private

    def load_advice_page
      AdvicePage.find_by_key(:baseload)
    end

    def chart_configuration(results)
      series_name = I18n.t('analytics.benchmarking.configuration.column_headings.baseload_per_pupil_w')
      chart_data = {}

      # Some charts also set x_max_value to 100 if there are metric values > 100
      # Removes issues with schools with large % changes breaking the charts
      #
      # This could be done by clipping values to 100.0 if the metric has a
      # unit of percentage/relative_percent
      results.each do |baseload_per_pupil|
        metric = baseload_per_pupil.one_year_baseload_per_pupil_kw
        next if metric.nil? || metric.nan? || metric.infinite?
        # for a percentage metric we'd multiply * 100.0
        # here we're converting from kW to W
        chart_data[baseload_per_pupil.school] = metric * 1000.0
      end

      # TODO need to improve chart display so it has a proper title and subtitle like our other charts,
      # that will be handled in a new chart component or view
      #
      # Other improvements: disable legend clicking, ensuring colour coding matches what we use elsewhere?
      {
        title: nil,
        x_axis: chart_data.keys.map(&:name),
        x_axis_ranges: nil,
        x_data: { series_name => chart_data.values },
        y_axis_label: I18n.t('chart_configuration.y_axis_label_name.kw'),
        chart1_type: :bar,
        chart1_subtype: :stacked,
        config_name: :baseload_per_pupil
      }
    end
  end
end
