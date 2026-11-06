module AlertFloorAreaMixin
  # for floor areas and pupils numbers varying over time
  private def floor_area(start_date = nil, end_date = nil)
    aggregate_meter.meter_floor_area(@school, start_date, end_date)
  end

  private def pupils(start_date = nil, end_date = nil)
    aggregate_meter.meter_number_of_pupils(@school, start_date, end_date)
  end
end
