# == Schema Information
#
# Table name: comparison_electricity_targets
#
#  current_target                          :float
#  current_year_kwh                        :float
#  current_year_percent_of_target_relative :float
#  current_year_target_kwh                 :float
#  id                                      :bigint(8)
#  school_id                               :bigint(8)        primary key
#  tracking_start_date                     :date
#
# Indexes
#
#  index_comparison_electricity_targets_on_school_id  (school_id) UNIQUE
#
class Comparison::ElectricityTargets < Comparison::View
  scope :with_data, -> { where.not(current_year_percent_of_target_relative: nil) }
  scope :sort_default, -> { order(current_year_percent_of_target_relative: :desc) }
end
