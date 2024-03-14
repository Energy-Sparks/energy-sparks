module Comparisons
  class AnnualStorageHeaterOutOfHoursUseController < BaseController
    private

    def headers
      [
        t('analytics.benchmarking.configuration.column_headings.school'),
        t('analytics.benchmarking.configuration.column_headings.school_day_open'),
        t('analytics.benchmarking.configuration.column_headings.overnight_charging'),
        t('analytics.benchmarking.configuration.column_headings.holiday'),
        t('analytics.benchmarking.configuration.column_headings.weekend'),
        t('analytics.benchmarking.configuration.column_headings.last_year_weekend_and_holiday_costs')
      ]
    end

    def key
      :annual_storage_heater_out_of_hours_use
    end

    def advice_page_key
      :storage_heaters
    end

    def load_data
      Comparison::AnnualStorageHeaterOutOfHoursUse.for_schools(@schools).with_data.sort_default
    end

    def create_charts(results)
      create_multi_chart(results, {
        schoolday_open_percent: :school_day_open,
        schoolday_closed_percent: :school_day_closed,
        holidays_percent: :holiday,
        weekends_percent: :weekend,
        }, 100.0, :percent)
    end
  end
end
