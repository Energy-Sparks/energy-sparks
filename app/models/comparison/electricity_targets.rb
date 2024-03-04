# == Schema Information
#
# Table name: electricity_targets
#
#  alert_generation_run_id                          :bigint(8)
#  current_year_kwh                                 :float
#  current_year_percent_of_target_relative          :float
#  current_year_target_kwh                          :float
#  current_year_unscaled_percent_of_target_relative :float
#  id                                               :bigint(8)
#  school_id                                        :bigint(8)
#  tracking_start_date                              :date
#  unscaled_target_kwh_to_date                      :float
#
class Comparison::ElectricityTargets < Comparison::View
  scope :with_data, -> { where.not(current_year_kwh: nil, current_year_target_kwh: nil) }
  scope :default_sort, -> { order(current_year_percent_of_target_relative: :desc) }
end
