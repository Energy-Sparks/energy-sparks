# == Schema Information
#
# Table name: comparison_heating_coming_on_too_early
#
#  alert_generation_run_id                  :bigint(8)
#  average_start_time_hh_mm                 :time
#  avg_week_start_time                      :time
#  gas_economic_tariff_changed_this_year    :boolean
#  id                                       :bigint(8)
#  one_year_optimum_start_saving_gbpcurrent :float
#  optimum_start_sensitivity                :float
#  rating                                   :float
#  regression_r2                            :float
#  regression_start_time                    :float
#  school_id                                :bigint(8)
#  start_time_standard_devation             :float
#
# Indexes
#
#  index_comparison_heating_coming_on_too_early_on_school_id  (school_id) UNIQUE
#
class Comparison::HeatingComingOnTooEarly < Comparison::View
  self.table_name = :comparison_heating_coming_on_too_early

  scope :with_data, -> { where.not(avg_week_start_time: nil, average_start_time_hh_mm: nil) }
  scope :sort_default, -> { joins(:school).order('schools.name') }

  def avg_week_start_time_to_time_of_day
    avg_week_start_time.nil? ? '' : TimeOfDay.from_time(avg_week_start_time)
  end

  def average_start_time_hh_mm_to_time_of_day
    average_start_time_hh_mm.nil? ? '' : TimeOfDay.from_time(average_start_time_hh_mm)
  end
end
