# == Schema Information
#
# Table name: comparison_annual_storage_heater_out_of_hours_uses
#
#  alert_generation_run_id  :bigint(8)
#  holidays_gbp             :float
#  holidays_percent         :float
#  id                       :bigint(8)
#  school_id                :bigint(8)
#  schoolday_closed_percent :float
#  schoolday_open_percent   :float
#  weekends_gbp             :float
#  weekends_percent         :float
#
# Indexes
#
#  idx_on_school_id_9addfaf1f6  (school_id) UNIQUE
#
class Comparison::AnnualStorageHeaterOutOfHoursUse < Comparison::View
  scope :with_data, -> { where.not(schoolday_open_percent: nil) }
  scope :sort_default, -> { order(schoolday_open_percent: :desc) }

  def weekend_and_holiday_gbp
    [weekends_gbp, holidays_gbp].compact.sum
  end
end
