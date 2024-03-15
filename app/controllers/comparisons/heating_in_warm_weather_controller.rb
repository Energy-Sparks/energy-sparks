module Comparisons
  class HeatingInWarmWeatherController < BaseController
    private

    def headers
      [
        t('analytics.benchmarking.configuration.column_headings.school'),
        t('analytics.benchmarking.configuration.column_headings.percentage_of_annual_heating_consumed_in_warm_weather'),
        t('analytics.benchmarking.configuration.column_headings.saving_through_turning_heating_off_in_warm_weather_kwh'),
        t('analytics.benchmarking.configuration.column_headings.saving_co2_kg'),
        t('analytics.benchmarking.configuration.column_headings.saving_£'),
        t('analytics.benchmarking.configuration.column_headings.number_of_days_heating_on_in_warm_weather'),
      ]
    end

    def key
      :heating_in_warm_weather
    end

    def advice_page_key
      :heating_control
    end

    def load_data
      Comparison::HeatingInWarmWeather.for_schools(@schools).with_data.sort_default
    end

    def create_charts(results)
      create_single_number_chart(results, :percent_of_annual_heating, nil, :percentage_of_annual_heating_consumed_in_warm_weather, :percent)
    end
  end
end
