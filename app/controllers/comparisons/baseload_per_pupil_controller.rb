module Comparisons
  class BaseloadPerPupilController < BaseController
    private

    def advice_page_key
      :baseload
    end

    def load_data
      Comparison::BaseloadPerPupil.where(school: @schools).where.not(one_year_baseload_per_pupil_kw: nil).order(one_year_baseload_per_pupil_kw: :desc)
    end

    def create_chart(results)
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

      create_chart_configuration(config_name: :baseload_per_pupil,
        chart_data: chart_data,
        series_name: I18n.t('analytics.benchmarking.configuration.column_headings.baseload_per_pupil_w'),
        y_axis_label: I18n.t('chart_configuration.y_axis_label_name.kw'))
    end
  end
end
