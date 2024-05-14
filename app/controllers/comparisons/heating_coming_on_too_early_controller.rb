# frozen_string_literal: true

module Comparisons
  class HeatingComingOnTooEarlyController < BaseController
    def index
      @headers_optimum_start_analysis = headers_optimum_start_analysis
      super
    end

    private

    def headers
      [t('analytics.benchmarking.configuration.column_headings.school'),
       t('analytics.benchmarking.configuration.column_headings.average_heating_start_time_last_week'),
       t('analytics.benchmarking.configuration.column_headings.average_heating_start_time_last_year'),
       t('analytics.benchmarking.configuration.column_headings.last_year_saving_if_improve_to_exemplar')]
    end

    def headers_optimum_start_analysis
      [t('analytics.benchmarking.configuration.column_headings.school'),
       t('analytics.benchmarking.configuration.column_headings.average_heating_start_time_last_year'),
       t('analytics.benchmarking.configuration.column_headings.standard_deviation_of_start_time__hours_last_year'),
       t('analytics.benchmarking.configuration.column_headings.optimum_start_rating'),
       t('analytics.benchmarking.configuration.column_headings.regression_model_optimum_start_time'),
       t('analytics.benchmarking.configuration.column_headings.regression_model_optimum_start_sensitivity_to_outside_temperature'),
       t('analytics.benchmarking.configuration.column_headings.regression_model_optimum_start_r2'),
       t('analytics.benchmarking.configuration.column_headings.average_heating_start_time_last_week')]
    end

    def key
      :heating_coming_on_too_early
    end

    def advice_page_key
      :heating_control
    end

    def load_data
      Comparison::HeatingComingOnTooEarly.for_schools(@schools)
    end

    def create_charts(results)
      @chart_heating_coming_on_too_early = create_chart(
        results,
        { avg_week_start_time_to_time_of_day: :average_heating_start_time_last_week },
        nil,
        :timeofday
      )
      @chart_heating_coming_on_too_early[:id] = :heating_coming_on_too_early

      @chart_optimum_start_analysis = create_chart(
        results,
        { average_start_time_hh_mm_to_time_of_day: :average_heating_start_time_last_year },
        nil,
        :timeofday
      )
      @chart_optimum_start_analysis[:id] = :optimum_start_analysis
      [true]
    end

    def table_names
      %i[table optimum_start_analysis]
    end
  end
end
