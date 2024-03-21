module Comparisons
  class ThermostatSensitivityController < BaseController
    private

    def headers
      [
        t('analytics.benchmarking.configuration.column_headings.school'),
        t('analytics.benchmarking.configuration.column_headings.last_year_saving_per_1c_reduction_in_thermostat')
      ]
    end

    def key
      :thermostat_sensitivity
    end

    def advice_page_key
      :heating_control
    end

    def load_data
      Comparison::ThermostatSensitivity.for_schools(@schools).with_data.sort_default
    end

    def create_charts(results)
      create_single_number_chart(results, :annual_saving_1_C_change_gbp, nil, :last_year_saving_per_1c_reduction_in_thermostat, :£)
    end
  end
end
