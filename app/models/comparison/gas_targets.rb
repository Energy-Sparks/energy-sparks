# == Schema Information
#
# Table name: gas_targets
#
#  alert_generation_run_id                 :bigint(8)
#  current_year_kwh                        :float
#  current_year_percent_of_target_relative :float
#  current_year_target_kwh                 :float
#  id                                      :bigint(8)
#  school_id                               :bigint(8)
#  tracking_start_date                     :date
#
class Comparison::GasTargets < Comparison::View
  scope :with_data, -> { where.not(current_year_percent_of_target_relative: nil) }
  scope :sort_default, -> { order(current_year_percent_of_target_relative: :desc) }

  def current_target
    school.current_target&.gas&.then(&:-@)
  end
end
