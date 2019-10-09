# Library of function to calculate energy usage for a school
# This library is included in the School model
module AmrUsage
  #
  # Get date of the last reading up to the given date
  # We take the start of the day because we're always interested in a full day
  # of readings. Want to avoid showing updates when we might be loading data.
  def last_reading_date(supply, to_date = Date.current)
    readings_with_selected_meters(supply, nil).where('reading_date < ?', to_date).maximum(:reading_date)
  end

  def earliest_reading_date(supply)
    readings_with_selected_meters(supply, nil).minimum(:reading_date)
  end

  def last_n_days_with_readings(supply, window = 7, to_date = Date.current)
    latest = self.last_reading_date(supply, to_date)
    latest.nil? ? nil : latest - window.days..latest
  end

private

  def readings_with_selected_meters(supply, meter)
    self.amr_validated_readings.where(conditional_supply(supply)).where(conditional_meter(meter))
  end

  def conditional_supply(supply)
    { meters: { meter_type: Meter.meter_types[supply] } } if supply
  end

  def conditional_meter(meter)
    { meters: { mpan_mprn: meter } } if meter.present? && meter != "all"
  end
end
