module Comparisons
  class AnnualElectricityCostsPerPupilController < BaseController
    private

    def colgroups
      [
        { label: '' },
        { label: t('analytics.benchmarking.configuration.column_groups.last_year'), colspan: 3 },
        { label: t('analytics.benchmarking.configuration.column_groups.last_year_per_pupil'), colspan: 3 },
        { label: '' }
      ]
    end

    def headers
      [
        t('analytics.benchmarking.configuration.column_headings.school'),
        t('kwh'),
        t('£'),
        t('co2'),
        t('kwh'),
        t('£'),
        t('co2'),
        t('analytics.benchmarking.configuration.column_headings.saving_if_matched_exemplar_school'),
      ]
    end

    def key
      :annual_electricity_costs_per_pupil
    end

    def advice_page_key
      :electricity_long_term
    end

    def load_data
      Comparison::AnnualElectricityCostsPerPupil.for_schools(@schools).with_data.sort_default
    end
  end
end
