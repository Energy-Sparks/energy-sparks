class UpdateHolidayUsageLastYearsToVersion2 < ActiveRecord::Migration[6.1]
  def change
    update_view :holiday_usage_last_years, version: 2, revert_to_version: 1
  end
end
