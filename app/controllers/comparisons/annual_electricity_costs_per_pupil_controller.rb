module Comparisons
  class AnnualElectricityCostsPerPupilController < BaseController
    private

    def headers
      [
        t('analytics.benchmarking.configuration.column_headings.school'),
        t('analytics.benchmarking.configuration.column_headings.last_year_electricity_£_pupil'),
        t('analytics.benchmarking.configuration.column_headings.last_year_electricity_£'),
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
      Comparison::AnnualElectricityCostsPerPupil.where(school: @schools).where.not(one_year_electricity_per_pupil_gbp: nil).order(one_year_electricity_per_pupil_gbp: :desc)
    end
  end
end
