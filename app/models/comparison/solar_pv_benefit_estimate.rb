# == Schema Information
#
# Table name: comparison_solar_pv_benefit_estimates
#
#  id                                            :bigint
#  electricity_economic_tariff_changed_this_year :boolean
#  one_year_saving_gbpcurrent                    :float
#  optimum_kwp                                   :float
#  optimum_mains_reduction_percent               :float
#  optimum_payback_years                         :float
#  alert_generation_run_id                       :bigint
#  school_id                                     :bigint
#
# Indexes
#
#  index_comparison_solar_pv_benefit_estimates_on_school_id  (school_id) UNIQUE
#
class Comparison::SolarPvBenefitEstimate < Comparison::View
  scope :with_data, -> { where.not(optimum_kwp: nil) }
  scope :sort_default, -> { order(optimum_kwp: :desc) }
end
