# == Schema Information
#
# Table name: comparison_electricity_targets
#
#  current_target                  :float
#  current_year_kwh                :float
#  current_year_target_kwh         :float
#  id                              :bigint(8)
#  previous_to_current_year_change :float
#  previous_year_kwh               :float
#  school_id                       :bigint(8)
#  tracking_start_date             :date
#
# Indexes
#
#  index_comparison_electricity_targets_on_school_id  (school_id) UNIQUE
#
class Comparison::ElectricityTargets < Comparison::View
  scope :with_data, -> { where.not(previous_to_current_year_change: nil) }
  scope :sort_default, -> { order(previous_to_current_year_change: :desc) }
end
