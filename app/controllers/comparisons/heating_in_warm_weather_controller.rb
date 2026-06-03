module Comparisons
  class HeatingInWarmWeatherController < BaseController
    private

    def headers
      Comparison::HeatingInWarmWeather.default_headers
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
      create_single_number_chart(results, :percent_of_annual_heating, 100.0, :percentage_of_annual_heating_consumed_in_warm_weather, :percent)
    end
  end
end
