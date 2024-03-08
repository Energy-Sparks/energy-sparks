# == Schema Information
#
# Table name: solar_pv_benefit_estimates
#
#  alert_generation_run_id                       :bigint(8)
#  electricity_economic_tariff_changed_this_year :boolean
#  id                                            :bigint(8)
#  one_year_saving_gbpcurrent                    :float
#  optimum_kwp                                   :float
#  optimum_mains_reduction_percent               :float
#  optimum_payback_years                         :float
#  school_id                                     :bigint(8)
#
class Comparison::SolarPvBenefitEstimate < Comparison::View
  scope :with_data, -> { where.not(optimum_kwp: nil) }
  scope :sort_default, -> { order(optimum_kwp: :desc) }
end
