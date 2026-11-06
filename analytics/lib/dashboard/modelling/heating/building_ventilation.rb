class BuildingVentilation
  OCCUPANCY_TEMPERATURE = 20.0
  FLOOR_HEIGHT = 3.0
  HEAT_CAPACITY_AIR = 0.00034 # kwh/m3/K (1000J/kg * 1.2kg/m3/K / 3,600,000 kWh/J)
  HUMAN_HEAT_GAIN = 0.06 # pupils = 60 W or 60 wh / hr
  RECOMMENDED_CLASSROOM_FLOOR_AREA_M2 = 70
  UNCONTROLLED_VENTILATION_AT_50_PA_M2_PER_M3_PER_HOUR = 10.0
  SHELTER_FACTOR = 0.07

  def initialize(school, heat_meter)
    @school     = school
    @heat_meter = heat_meter
  end

  def ventilation_calculations(litres_per_second_per_person: [5.0, 10.0], occupancy_temperature: OCCUPANCY_TEMPERATURE)
    results = heating_hot_water_split

    results.merge!(
      {
        annual_human_gain_kwh:            annual_occupancy_hours * HUMAN_HEAT_GAIN * school_occupants,
        days_real_meter_data_analysed:    days_meter_data,
        annual_kwh:                       annual_kwh,
        classrooms_uncontrolled_ventilation_m3_per_hour: classrooms_uncontrolled_ventilation_m3_per_hour,
        classrooms_uncontrolled_ventilation_ach: classrooms_uncontrolled_ventilation_ach
      }
    )

    heating_hot_water_split

    annual_occupied_degree_hours = (start_date..end_date).sum{ |date| degree_hours(date, occupancy_temperature: occupancy_temperature) }

    litres_per_second_per_person.each do |litres_per_second|
      hourly_controlled_ventilation_m3 = school_occupants * litres_per_second * 60.0 * 60.0 / 1000.0

      annual_heat_loss_kwh = hourly_controlled_ventilation_m3 * annual_occupied_degree_hours * HEAT_CAPACITY_AIR

      res = {
        hourly_controlled_ventilation_m3: hourly_controlled_ventilation_m3,
        approx_ach:                       hourly_controlled_ventilation_m3 / (FLOOR_HEIGHT * classrooms_floor_area_m2),
        annual_heat_loss_kwh:             annual_heat_loss_kwh,
        ventilation_percent_kwh:          annual_heat_loss_kwh  / annual_kwh,
        ventilation_heating_percent_kwh:  annual_heat_loss_kwh / results[:heating_kwh],
        ventilation_percent_human_gain:   annual_heat_loss_kwh / results[:annual_human_gain_kwh]
      }
      results.merge!(res.transform_keys { |k|  "#{k}_at_#{litres_per_second.round(0)}_litres".to_sym })
    end

    ap results

    results
  end

  private

  def heating_hot_water_split
    splitter = HotWaterHeatingSplitter.new(@school)
    splitter.aggregate_heating_hot_water_split(start_date, end_date)
  end

  def approx_surface_area_to_volume_ratio(floor_area, storeys, floor_height)
    volume = floor_area * floor_height
    ground_floor_area = floor_area / storeys
    length = ground_floor_area ** 0.5
    surface_area = ground_floor_area + 4 * length * storeys * floor_height
    surface_area / volume
  end

  def classrooms_external_surface_area_m2
    classroom_external_surface_area_m2 * approx_classrooms
  end

  def classroom_external_surface_area_m2
    RECOMMENDED_CLASSROOM_FLOOR_AREA_M2 + FLOOR_HEIGHT * 2 * (RECOMMENDED_CLASSROOM_FLOOR_AREA_M2 ** 0.5)
  end

  def classrooms_floor_area_m2
    RECOMMENDED_CLASSROOM_FLOOR_AREA_M2 * approx_classrooms
  end

  def classroom_volume_m3
    RECOMMENDED_CLASSROOM_FLOOR_AREA_M2 * FLOOR_HEIGHT
  end

  def classrooms_volume_m3
    classroom_volume_m3 * approx_classrooms
  end

  def classrooms_uncontrolled_ventilation_m3_per_hour
    UNCONTROLLED_VENTILATION_AT_50_PA_M2_PER_M3_PER_HOUR * SHELTER_FACTOR * classrooms_external_surface_area_m2
  end

  def classrooms_uncontrolled_ventilation_ach
    classrooms_uncontrolled_ventilation_m3_per_hour / classrooms_volume_m3
  end

  def approx_classrooms
    case @school.school_type.to_sym
    when :primary, :infant, :junior, :special
      if @school.number_of_pupils < 110
        3
      elsif @school.number_of_pupils < 210
        7
      else
        @school.number_of_pupils / 30.0
      end
    when :secondary, :middle, :mixed_primary_and_secondary
      @school.number_of_pupils / 30.0
    else
      raise EnergySparksUnexpectedStateException, "Unknown school type #{school_type}"
    end
  end

  def annual_kwh
    @annual_kwh ||= @heat_meter.amr_data.kwh_date_range(start_date, end_date)
  end

  def degree_hours(date, occupancy_temperature: OCCUPANCY_TEMPERATURE)
    return 0.0 unless occupied?(date) && heating_model.heating_on?(date)

    outside_temperatures = @school.temperatures.one_days_data_x48(date)

    degree_half_hours = occupancy_half_hours_x48.map.with_index do |occupied, index|
      occupied >= 1 ? [occupancy_temperature - outside_temperatures[index], 0.0].max : 0.0
    end

    degree_half_hours.sum / 2.0
  end

  def school_occupants
    @school.number_of_pupils * 1.1
  end

  def annual_occupancy_hours
    school_days = (start_date..end_date).count{ |date| occupied?(date) }
    school_days * (occupancy_half_hours_x48.sum / 2.0)
  end

  def occupied?(date)
    @school.holidays.occupied?(date)
  end

  def heating_model
    @heating_model ||= calculate_heating_model
  end

  def calculate_heating_model
    last_year = SchoolDatePeriod.new(:year_to_date, 'ventilation', start_date, end_date)
    @heat_meter.heating_model(last_year)
  end

  def start_date
    [end_date - 364, @heat_meter.amr_data.start_date].max
  end

  def end_date
    @heat_meter.amr_data.end_date
  end

  def days_meter_data
    (end_date - start_date + 1).to_i
  end

  def pro_rata
    365.0 / days_meter_data
  end

  def occupancy_half_hours_x48
    @occupancy_hours ||= calculate_occupancy_half_hours_x48
  end

  def calculate_occupancy_half_hours_x48
    start_time = @school.open_time
    open_time = start_time..@school.close_time
    DateTimeHelper.weighted_x48_vector_multiple_ranges([open_time])
  end
end
