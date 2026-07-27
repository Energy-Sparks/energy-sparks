# == Schema Information
#
# Table name: comparison_solar_pv_benefit_estimates
#
#  id                                            :bigint(8)
#  electricity_economic_tariff_changed_this_year :boolean
#  one_year_saving_gbpcurrent                    :float
#  optimum_kwp                                   :float
#  optimum_mains_reduction_percent               :float
#  optimum_payback_years                         :float
#  alert_generation_run_id                       :bigint(8)
#  school_id                                     :bigint(8)
#
# Indexes
#
#  index_comparison_solar_pv_benefit_estimates_on_school_id  (school_id) UNIQUE
#
class Comparison::SolarPvBenefitEstimate < Comparison::View
  scope :with_data, -> { where.not(optimum_kwp: nil) }
  scope :sort_default, -> { order(optimum_mains_reduction_percent: :desc) }

  def self.report_headers
    [
      I18n.t('analytics.benchmarking.configuration.column_headings.school'),
      I18n.t('analytics.benchmarking.configuration.column_headings.size_kwp'),
      I18n.t('analytics.benchmarking.configuration.column_headings.payback_years'),
      I18n.t('analytics.benchmarking.configuration.column_headings.reduction_in_mains_consumption_pct'),
      I18n.t('analytics.benchmarking.configuration.column_headings.saving_optimal_panels')
    ]
  end
end
