# == Schema Information
#
# Table name: annual_storage_heater_out_of_hours_uses
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
class Comparison::AnnualStorageHeaterOutOfHoursUse < Comparison::View
  scope :with_data, -> { where.not(schoolday_open_percent: nil) }
  scope :sort_default, -> { order(schoolday_open_percent: :desc) }

  def weekend_and_holiday_gbp
    [weekends_gbp, holidays_gbp].compact.sum
  end
end
