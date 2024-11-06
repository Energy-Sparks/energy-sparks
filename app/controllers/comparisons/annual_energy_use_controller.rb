module Comparisons
  class AnnualEnergyUseController < BaseController
    private

    def header_groups
      [{ label: '',
         headers: [
           t('analytics.benchmarking.configuration.column_headings.school'),
           t('comparisons.column_headings.recent_data')
         ] },
       { label: t('analytics.benchmarking.configuration.column_groups.electricity_consumption'),
         headers: [
           t('kwh'),
           t('£'),
           t('co2')
         ] },
       { label: t('analytics.benchmarking.configuration.column_groups.gas_consumption'),
         headers: [
           t('kwh'),
           t('£'),
           t('co2')
         ] },
       { label: t('analytics.benchmarking.configuration.column_groups.storage_heater_consumption'),
         headers: [
           t('kwh'),
           t('£'),
           t('co2')
         ] },
       { label: '',
         headers: [
           t('analytics.benchmarking.configuration.column_headings.type'),
           t('analytics.benchmarking.configuration.column_headings.pupils'),
           t('analytics.benchmarking.configuration.column_headings.floor_area')
         ] }]
    end

    def key
      :annual_energy_use
    end

    def load_data
      Comparison::AnnualEnergyUse.for_schools(@schools).with_data.sort_default
    end

    def create_charts(results)
      # i18n-tasks-use t('analytics.benchmarking.configuration.column_headings.electricity')
      # i18n-tasks-use t('analytics.benchmarking.configuration.column_headings.gas')
      # i18n-tasks-use t('analytics.benchmarking.configuration.column_headings.storage_heaters')
      create_multi_chart(results, {
        electricity_last_year_kwh: :electricity,
        gas_last_year_kwh: :gas,
        storage_heaters_last_year_kwh: :storage_heaters,
        }, nil, :kwh)
    end
  end
end
