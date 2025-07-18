# == Schema Information
#
# Table name: comparison_annual_energy_costs
#
#  alert_generation_run_id       :bigint(8)
#  floor_area                    :float
#  id                            :bigint(8)
#  last_year_co2_tonnes          :float
#  last_year_electricity         :float
#  last_year_gas                 :float
#  last_year_gbp                 :float
#  last_year_kwh                 :float
#  last_year_storage_heaters     :float
#  one_year_energy_per_pupil_gbp :float
#  pupils                        :float
#  school_id                     :bigint(8)
#  school_type_name              :text
#
# Indexes
#
#  index_comparison_annual_energy_costs_on_school_id  (school_id) UNIQUE
#
class Comparison::AnnualEnergyCosts < Comparison::View
  scope :sort_default, -> { order('last_year_gbp DESC NULLS LAST') }
end
