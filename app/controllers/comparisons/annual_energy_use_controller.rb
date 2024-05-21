module Comparisons
  class AnnualEnergyUseController < BaseController
    private

    def colgroups
      [
        { label: '', colspan: 2 },
        { label: t('analytics.benchmarking.configuration.column_groups.electricity_consumption'), colspan: 3 },
        { label: t('analytics.benchmarking.configuration.column_groups.gas_consumption'), colspan: 3 },
        { label: t('analytics.benchmarking.configuration.column_groups.storage_heater_consumption'), colspan: 3 },
        { label: '', colspan: 3 }
      ]
    end

    def headers
      [
        t('analytics.benchmarking.configuration.column_headings.school'),
        t('comparisons.column_headings.recent_data'),
        t('kwh'),
        t('£'),
        t('co2'),
        t('kwh'),
        t('£'),
        t('co2'),
        t('kwh'),
        t('£'),
        t('co2'),
        t('analytics.benchmarking.configuration.column_headings.type'),
        t('analytics.benchmarking.configuration.column_headings.pupils'),
        t('analytics.benchmarking.configuration.column_headings.floor_area')
      ]
    end

    def key
      :annual_energy_use
    end

    def advice_page_key
      :total_energy_use
    end

    def load_data
      Comparison::AnnualEnergyUse.for_schools(@schools).with_data.sort_default
    end

    def create_charts(results)
      create_multi_chart(results, {
        electricity_last_year_kwh: :electricity,
        gas_last_year_kwh: :gas,
        storage_heaters_last_year_kwh: :storage_heaters,
        }, nil, :kwh)
    end
  end
end
