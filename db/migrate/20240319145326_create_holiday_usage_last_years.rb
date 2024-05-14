class CreateHolidayUsageLastYears < ActiveRecord::Migration[6.1]
  def change
    create_view :holiday_usage_last_years
  end
end
