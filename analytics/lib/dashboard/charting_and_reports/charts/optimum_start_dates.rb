class OptimumStartDates
  def initialize(meter_collection)
    @meter_collection = meter_collection
  end

  def list_of_dates
    @optimum_start_days ||= weeks_with_large_morning_temperature_range.reverse
  end

  private
  def weeks_with_large_morning_temperature_range
    selected_weeks = []
    school_weeks_with_heating_on.each do |monday_to_friday|
      temperature_difference = morning_temperature_range(monday_to_friday)
      selected_weeks += monday_to_friday.to_a if temperature_difference > 5.0
    end
    selected_weeks
  end

  def morning_temperature_range(temp_range)
    ranges = temp_range.to_a.map { |date| @meter_collection.temperatures.average_temperature_in_time_range(date, 0, 10) }
    ranges.max - ranges.min
  end

  def school_weeks_with_heating_on
    weeks = []
    adj_start = [1, 0, 6, 5, 4, 3, 2, 1]
    adj_end   = [-7, 0, -1, 2, -3, -4, -5, -6]
    first_monday = start_date + adj_start[start_date.wday]
    last_monday = end_date + adj_end[start_date.wday]
    (first_monday..last_monday).step(7) do |monday|
      heating_on_all_week = (monday..(monday+4)).to_a.all? { |date| heating_model.heating_on?(date) }
      weeks.push(monday..(monday+4)) if heating_on_all_week
    end
    weeks
  end

  def heating_model
    @heating_model ||= calculate_heating_model
  end

  def start_date
    end_date - 364
  end

  def end_date
    @meter_collection.aggregated_heat_meters.amr_data.end_date
  end

  def calculate_heating_model
    end_date = @meter_collection.aggregated_heat_meters.amr_data.end_date
    start_date = [end_date - 364, @meter_collection.aggregated_heat_meters.amr_data.start_date].max
    period = new_school_period(start_date, end_date)
    model = @meter_collection.aggregated_heat_meters.heating_model(period, :best)
    raise EnergySparksNotEnoughDataException, 'Not enough data for to calculate model for optimum start analysis' unless model.enough_samples_for_good_fit
    model
  end

  def new_school_period(start_date, end_date, name_suffix = '')
    SchoolDatePeriod.new(@optimum_start, 'Optimum Start Period', start_date, end_date)
  end
end