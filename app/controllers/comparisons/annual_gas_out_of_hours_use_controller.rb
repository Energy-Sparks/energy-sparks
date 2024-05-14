module Comparisons
  class AnnualGasOutOfHoursUseController < BaseController
    private

    def headers
      [
        t('analytics.benchmarking.configuration.column_headings.school'),
        t('analytics.benchmarking.configuration.column_headings.school_day_open'),
        t('analytics.benchmarking.configuration.column_headings.school_day_closed'),
        t('analytics.benchmarking.configuration.column_headings.holiday'),
        t('analytics.benchmarking.configuration.column_headings.weekend'),
        t('analytics.benchmarking.configuration.column_headings.community'),
        t('analytics.benchmarking.configuration.column_headings.community_usage_cost'),
        t('analytics.benchmarking.configuration.column_headings.last_year_out_of_hours_cost'),
        t('analytics.benchmarking.configuration.column_headings.saving_if_improve_to_exemplar'),
      ]
    end

    def key
      :annual_gas_out_of_hours_use
    end

    def advice_page_key
      :gas_out_of_hours
    end

    def load_data
      Comparison::AnnualGasOutOfHoursUse.for_schools(@schools).with_data.sort_default
    end

    def create_charts(results)
      create_multi_chart(results, {
        schoolday_open_percent: :school_day_open,
        schoolday_closed_percent: :school_day_closed,
        holidays_percent: :holiday,
        weekends_percent: :weekend,
        community_percent: :community
        }, 100.0, :percent)
    end
  end
end
