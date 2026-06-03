# frozen_string_literal: true

# Calculates interpolated weighted average power consumption
class PowerConsumptionService
  MAXMATCHDATES = 5
  MIDDLEOFBUCKET15MINS = 15 * 60 # half hour kWh reading centred 15 minutes into bucket
  SECONDSINBUCKET = 30 * 60

  # Factory method to create light-weight service that wraps a simple interpolator
  def self.create_service(aggregate_school, meter, day = Date.today)
    dates = matching_dates(day, aggregate_school.holidays, meter.amr_data.start_date, meter.amr_data.end_date).sort
    weighted_dates = calculate_weighted_dates(dates)
    weighted_historic_kwh_x48 = calculate_weighted_kwh_x48(weighted_dates, meter.amr_data)

    seconds_in_into_day_to_kwh = weighted_historic_kwh_x48.map.with_index { |kwh, hhi| [hhi * SECONDSINBUCKET + MIDDLEOFBUCKET15MINS, kwh] }.to_h
    PowerConsumptionService.new(Interpolate::Points.new(seconds_in_into_day_to_kwh))
  end

  def initialize(interpolator)
    @interpolator = interpolator
  end

  def perform(time = Time.now)
    seconds_since_midnight = (time.to_i - midnight(time).to_i).to_f
    2.0 * @interpolator.at(seconds_since_midnight)
  end

  private

  def midnight(t)
    Time.new(t.year, t.month, t.day)
  end

  def self.matching_dates(day, holidays, start_date, end_date)
    dates = []
    day_type = holidays.day_type(day)
    date = end_date
    while date >= start_date
      dates.push(date) if holidays.day_type(date) == day_type
      break if dates.length == MAXMATCHDATES

      date -= 1
    end
    dates
  end

  def self.calculate_weighted_dates(dates)
    weighted_dates = dates.map.with_index { |d, w| [d, w + 1] }.to_h
    total_weight = weighted_dates.values.sum
    weighted_dates.transform_values { |w| w.to_f / total_weight }
  end

  def self.calculate_weighted_kwh_x48(weighted_dates, amr_data)
    kwh_component_x48 = weighted_dates.map do |date, weight|
      AMRData.fast_multiply_x48_x_scalar(amr_data.days_kwh_x48(date), weight)
    end
    AMRData.fast_add_multiple_x48_x_x48(kwh_component_x48)
  end
end
