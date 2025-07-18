# implements equivalences from electricity, gas kWh to equivlence
# derives data from existing EnergyEquivalences::ENERGY_EQUIVALENCES data
class EnergyConversions
  def initialize(meter_collection)
    @meter_collection = meter_collection
    @conversion_list = EnergyConversions.front_end_conversion_list
  end

  def self.front_end_conversion_list
    conversion_choices = EnergyConversions.generate_conversion_list
    conversion_choices.merge(self.additional_frontend_only_variable_descriptions)
  end

  def front_end_convert(convert_to, time_period, meter_type)
    conversion = @conversion_list[convert_to]

    via_unit      = conversion[:via]
    key           = conversion[:primary_key]
    converted_to  = conversion[:converted_to]

    results = convert(key, via_unit, time_period, meter_type, converted_to)

    results.merge!(scaled_results(conversion, time_period, results)) if conversion.key?(:equivalence_timescale)

    results
  end

  def convert(convert_to, kwh_co2_or_£, time_period, meter_type, units_of_equivalance = nil)
    grid_intensity = grid_intensity(time_period, meter_type)
    basic_unit = [:kwh, :co2, :£].include?(convert_to)
    raise EnergySparksUnexpectedStateException.new('Expecting 2nd parameter to be same as first for kwh, co2 or £') if basic_unit && convert_to != kwh_co2_or_£
    configuration = basic_unit ? nil : EnergyEquivalences.equivalence_conversion_configuration(convert_to, kwh_co2_or_£, grid_intensity)
    conversion = basic_unit ? 1.0 : configuration[:rate]
    kwh, date1, date2 = scalar_value(time_period, meter_type, :kwh, true)
    value = kwh_co2_or_£ == :kwh ? kwh : scalar_value(time_period, meter_type, kwh_co2_or_£, false)
    calc = basic_unit ? 'no conversion' : calculation_description(kwh, meter_type, convert_to, kwh_co2_or_£, grid_intensity)
    equivalence = value / conversion
    formatted_equivalence = format_equivalance_for_front_end(units_of_equivalance, equivalence)

    {
      equivalence:                  equivalence,
      formatted_equivalence:        formatted_equivalence,
      old_formatted_equivalence:    FormatEnergyUnit.format(units_of_equivalance, equivalence),
      units_of_equivalance:         units_of_equivalance,
      show_equivalence:             show_equivalence(units_of_equivalance, equivalence),
      kwh:                          kwh,
      formatted_kwh:                FormatEnergyUnit.format(:kwh, kwh),
      value_in_via_units:           value, # in kWh, CO2 or £
      formatted_via_units_value:    FormatEnergyUnit.format(kwh_co2_or_£, value),
      conversion:                   conversion,
      conversion_factor:            kwh == 0.0 ? nil : (value / kwh),
      via:                          kwh_co2_or_£,
      from_date:                    date1,
      to_date:                      date2,
      calculation_description:      calc,
      adult_dashboard_wording:      adult_dashboard_description(configuration, kwh_co2_or_£, formatted_equivalence)
    }
  end

  private def grid_intensity(time_scale, meter_type)
    if %i[electricity storage_heaters].include?(meter_type)
      CalculateAggregateValues.new(@meter_collection).uk_electricity_grid_carbon_intensity_for_period_kg_per_kwh(time_scale)
    else
      EnergyEquivalences::UK_ELECTRIC_GRID_CO2_KG_KWH # default for cashing purposes if not electricity
    end
  end

  private def adult_dashboard_description(configuration, kwh_co2_or_£, formatted_equivalence)
    !configuration.nil? && configuration.key?(:adult_dashboard_wording) ? sprintf(configuration[:adult_dashboard_wording], formatted_equivalence) : 'No adult dashboard wording'
  end

  private def calculation_description(kwh, fuel_type, equiv_type, kwh_co2_or_£, grid_intensity)
    fuel_type = :electricity if fuel_type == :allelectricity_unmodified
    _val, _equ, calc, in_text, out_text = EnergyEquivalences.convert(kwh, :kwh, fuel_type, equiv_type, equiv_type, kwh_co2_or_£, grid_intensity)
    in_text + out_text + calc
  end

  protected def scalar_value(time_period, meter_type, kwh_co2_or_£, with_dates)
    if with_dates
      CalculateAggregateValues.new(@meter_collection).aggregate_value_with_dates(time_period, meter_type, kwh_co2_or_£)
    else
      CalculateAggregateValues.new(@meter_collection).aggregate_value(time_period, meter_type, kwh_co2_or_£)
    end
  end

  def conversion_choices(kwh_co2_or_£)
    EnergyEquivalences.equivalence_choice_by_via_type(kwh_co2_or_£)
  end

  private def scaled_results(conversion, time_period, unscaled_results)
    scale = scale_conversion_period(time_period, conversion[:equivalence_timescale])
    scaled_equivalence = unscaled_results[:equivalence] * scale
    old_formatted_equivalence = FormatEnergyUnit.format(conversion[:timescale_units], scaled_equivalence)
    formatted_equivalence = format_equivalance_for_front_end(conversion[:timescale_units], scaled_equivalence)
    {
      equivalence_scaled_to_time_period:        scaled_equivalence,
      old_formatted_equivalence_to_time_period: old_formatted_equivalence,
      formatted_equivalence_to_time_period:     formatted_equivalence
    }
  end

  private def show_equivalence(units_of_equivalance, equivalence)
    equivalence >= 1.0
  end

  # temporary/short term adjustment to meet front end requirements
  private def format_equivalance_for_front_end(units_of_equivalance, equivalence)
    return FormatEnergyUnit.format(units_of_equivalance, equivalence) if %i[kwh kg £ km].include?(units_of_equivalance)
    return FormatEnergyUnit.format(:kg, equivalence) if units_of_equivalance == :co2
    if %i[onshore_wind_turbine_hours offshore_wind_turbine_hours hour].include?(units_of_equivalance)
      return FormatEnergyUnit.format(:years, equivalence / 24.0 / 365.0)
    else
      return FormatEnergyUnit.format(Float, equivalence)
    end
  end

  # scale conversion to time period of equivelance
  # e.g. if a request is made to provide an equivalence of 1 week of school electricity use
  #      but for example the conversion constants are in years, divided the conversion by 52 weeks/year
  private def scale_conversion_period(time_period, equivalence_timescale)
    school_period = time_period.keys[0]
    school_period_days = days_for_period(school_period)
    equivalence_period_days = days_for_period(equivalence_timescale)
    equivalence_period_days / school_period_days
  end

  private def days_for_period(period)
    case period
    when :year, :academicyear
      365.0
    when :month
      (365.0 / 12.0)
    when :week, :schoolweek, :workweek
      7.0
    when :day
      1.0
    when :hour
      (1.0 / 24.0)
    when :working_hours
      (365.0 * 24.0) / (39.0 * 5.0 * 6.0) / 24.0
    else
      period_description = period.nil? ? 'nil' : period.to_s
      raise EnergySparksUnexpectedStateException.new("Unexpected period for equivalence #{period_description}")
    end
  end

  # returns for example :ice_car_co2_km
  private_class_method def self.key_for_equivalence_conversion(type, via, convert_to)
    "#{type}_#{via}_#{convert_to}".to_sym
  end

  # converts energy_equivalence_conversions ENERGY_EQUIVALENCES to form flattened choice of conversions for the from end
  def self.generate_conversion_list(grid_intensity = EnergyEquivalences::UK_ELECTRIC_GRID_CO2_KG_KWH)
    conversions = {}
    EnergyEquivalences.equivalence_types.each do |conversion_key|
      conversion_data = EnergyEquivalences.equivalence_configuration(conversion_key, grid_intensity)
      next unless conversion_data.key?(:convert_to)
      conversion_data[:conversions].each do |via, via_data|
        next unless via_data.key?(:front_end_description)
        front_end_sym = key_for_equivalence_conversion(conversion_key, via, conversion_data[:convert_to])
        conversions[front_end_sym] = create_description(conversion_key, conversion_data, via, via_data)
      end
    end
    conversions
  end

  private_class_method def self.create_description(conversion_key, conversion_data, via, via_data)
    description = {
      description:              via_data[:front_end_description],
      adult_dashboard_wording:  via_data[:adult_dashboard_wording],
      via:                      via,
      converted_to:             conversion_data[:convert_to],
      primary_key:              conversion_key
    }
    merge_in_additional_information(description, via_data, :calculation_variables)
    merge_in_additional_information(description, conversion_data, :equivalence_timescale)
    merge_in_additional_information(description, conversion_data, :timescale_units)
    description
  end

  # should be private, but had to make public because Ruby doesn't handle this well
  def self.additional_frontend_only_variable_descriptions
    {
      kwh: {
        description:    'meter data in kWh',
        via:            :kwh,
        converted_to:   :kwh,
        primary_key:    :kwh
      },
      co2: {
        description:    'meter data in co2',
        via:            :co2,
        converted_to:   :co2,
        primary_key:    :co2
      },
      £: {
        description:    'meter data in £',
        via:            :£,
        converted_to:   :£,
        primary_key:    :£
      }
    }
  end

  private_class_method def self.merge_in_additional_information(conversions, from_hash, from_key)
    conversions.merge!(from_key => from_hash[from_key]) if from_hash.key?(from_key)
  end
end

class EnergyConversionsOutOfHours < EnergyConversions
  def self.random_out_of_hours_to_exemplar_percent_improvement(school, fuel_type, exemplar_percent)
    equivalence = EnergyConversionsOutOfHours.new(school)
    equivalences = generate_conversion_list
    random_index = Random.rand(generate_conversion_list.length)
    equivalence.front_end_convert(EnergyConversionsOutOfHours.generate_conversion_list.keys[random_index], { year: 0}, fuel_type, exemplar_percent)
  end

  def front_end_convert(convert_to, time_period, meter_type, exemplar_percent)
    @exemplar_percent = exemplar_percent
    results = super(convert_to, time_period, meter_type)
    conversion = @conversion_list[convert_to]
    kwh_co2_or_£ = conversion[:via]
    _examplar_saving, percent_saving_to_exemplar = saving_to_examplar(time_period, meter_type, kwh_co2_or_£, exemplar_percent)
    results[:examplar_percent_saving] = percent_saving_to_exemplar
    results
  end

  protected def scalar_value(time_period, meter_type, kwh_co2_or_£, _with_dates)
    examplar_saving, _percent_saving_to_exemplar = saving_to_examplar(time_period, meter_type, kwh_co2_or_£, @exemplar_percent)
    examplar_saving
  end

  private def saving_to_examplar(time_period, meter_type, kwh_co2_or_£, exemplar_percent)
    daytype_breakdown = CalculateAggregateValues.new(@meter_collection).day_type_breakdown(time_period, meter_type, kwh_co2_or_£)
    out_of_hours_value = daytype_breakdown.select{ |daytype, value| daytype != 'School Day Open' }.values.sum
    total_value = daytype_breakdown.values.sum
    percent_out_of_hours = out_of_hours_value / total_value
    percent_saving_to_exemplar = percent_out_of_hours - exemplar_percent
    examplar_saving = total_value * percent_saving_to_exemplar
    [examplar_saving, percent_saving_to_exemplar]
  end
end
