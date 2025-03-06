# == Schema Information
#
# Table name: comparison_hot_water_efficiencies
#
#  alert_generation_run_id                    :bigint(8)
#  avg_gas_per_pupil_gbp                      :float
#  benchmark_existing_gas_efficiency          :float
#  benchmark_gas_better_control_saving_gbp    :float
#  benchmark_point_of_use_electric_saving_gbp :float
#  id                                         :bigint(8)
#  school_id                                  :bigint(8)
#
# Indexes
#
#  index_comparison_hot_water_efficiencies_on_school_id  (school_id) UNIQUE
#
class Comparison::HotWaterEfficiency < Comparison::View
  scope :with_data, -> { where.not(avg_gas_per_pupil_gbp: [nil, 0.0]) }
  scope :sort_default, -> { order(avg_gas_per_pupil_gbp: :desc) }
end
