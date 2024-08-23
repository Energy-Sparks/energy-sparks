class PupilRemindersComponent < DashboardRemindersComponent
  def temperature_observations
    @school.observations.temperature
  end

  def show_temperature_observations?
    site_settings.temperature_recording_month_numbers.include?(Time.zone.today.month)
  end
end
