module Comparisons
  class ThermostaticControlController < BaseController
    private

    def headers
      [
        t('analytics.benchmarking.configuration.column_headings.school'),
        t('analytics.benchmarking.configuration.column_headings.thermostatic_r2'),
        t('analytics.benchmarking.configuration.column_headings.saving_through_improved_thermostatic_control'),
      ]
    end

    def key
      :thermostatic_control
    end

    def load_data
      Comparison::ThermostaticControl.for_schools(@schools).with_data.sort_default
    end

    def create_charts(results)
      create_single_number_chart(results, :r2, nil, :thermostatic_r2, :values)
    end
  end
end
