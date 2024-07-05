# frozen_string_literal: true

module Comparisons
  class HeatingVsHotWaterController < BaseController
    def unlisted
      @unlisted_swimming_pool = true
      super
    end

    private

    def header_groups
      [{ label: '',
         headers: [t('analytics.benchmarking.configuration.column_headings.school')] },
       { label: t('analytics.benchmarking.configuration.column_groups.kwh'),
         headers: [
           t('analytics.benchmarking.configuration.column_headings.gas'),
           t('analytics.benchmarking.configuration.column_headings.hot_water_gas'),
           t('analytics.benchmarking.configuration.column_headings.heating_gas')
         ] },
       { label: '',
         headers: [t('analytics.benchmarking.configuration.column_headings.percentage_of_gas_use_for_hot_water')] }]
    end

    def key
      :heating_vs_hot_water
    end

    def advice_page_key
      :hot_water
    end

    def load_data
      Comparison::HeatingVsHotWater.for_schools(@schools)
                                   .where.not(last_year_gas_kwh: nil)
                                   .where.not(estimated_hot_water_gas_kwh: nil)
                                   .without_swimming_pool
                                   .order(estimated_hot_water_percentage: :desc)
    end

    def unlisted_message(count)
      I18n.t('comparisons.hot_water_efficiency.unlisted.message', count: count)
    end
  end
end
