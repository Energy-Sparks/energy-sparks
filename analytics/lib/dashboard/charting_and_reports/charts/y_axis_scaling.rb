# handles the scaling of the y-axis
# Units:      kWh, kW, CO2, £, Library Books
# Scaling:    none, per pupil, per floor area,
#             per 200 pupils (primary representation), per 1000 pupils (secondary)
#
# ultimately it might have to support some degree day normalisation
# TODO (PH,5Jun2018) this class doesn't really know whether its a global class or an instance at the moment

class YAxisScaling
  include Logging
  attr_reader :units, :scaling_factors

  def initialize
    @@units = %i[kwh kw co2 £ £current library_books] # rubocop:disable Style/ClassVars
    @@scaling_factors = %i[none per_pupil per_floor_area per_200_pupils per_1000_pupils] # rubocop:disable Style/ClassVars
  end

  def self.unit_description(unit, scaling_factor_type, value)
    val_str = value.nil? ? 'NA' : value
    Logging.logger.debug "Y axis scaling for unit =#{unit} type = #{scaling_factor_type} value = #{val_str}"
    factor_type_description = {
      none:             nil,
      per_pupil:        'per pupil',
      per_floor_area:   'per floor area (m2)',
      per_200_pupils:   'per 200 pupil (average size primary school)',
      per_1000_pupils:  'per 1000 pupil (average size secondary school)'
    }
    # dummy insert of 10 and its subsequent removal is a fudge to
    # offset formatting change in FormatUnit which removes the
    # unit e.g. £ if the value is nil PH 20Nov2019
    formatted_value = FormatUnit.format(unit, 10).gsub('10','').strip
    unless scaling_factor_type.nil? || scaling_factor_type == :none
      formatted_value += '/' + factor_type_description[scaling_factor_type]
    end
    formatted_value
  end

  def scaling_factor(scaling_factor_type, meter_collection)
    factor = nil
    case scaling_factor_type
    when :none
      factor = 1.0
    when :per_pupil
      factor = 1.0 / meter_collection.number_of_pupils
    when :per_floor_area
      factor = 1.0 / meter_collection.floor_area
    when :per_200_pupils
      factor = scaling_factor(:per_pupil, meter_collection) * 200.0
    when :per_1000_pupils
      factor = scaling_factor(:per_pupil, meter_collection) * 1000.0
    else
      raise "Error: unknown scaling factor #{scaling_factor_type}" unless scaling_factor_type.nil?
      raise 'Error: nil scaling factor'
    end
    factor
  end

  def self.convert(from_unit, to_unit, fuel_type, from_value, round, meter_collection)
    # TODO(PH, 17Nov2022) not tested as only called by simulator advice
    val = YAxisScaling.scale(from_unit, to_unit, from_value, fuel_type, meter_collection)
    round ? FormatUnit.scale_num(val) : val
  end

  def self.convert_multiple(from_unit, to_units, fuel_type, from_value, round = true)
    converted_values = []
    to_units.each do |to_unit|
      converted_values.push(convert(from_unit, to_unit, fuel_type, from_value))
    end
    converted_values
  end

  def scale(from_unit, to_unit, val, fuel_type, meter_collection)
    return val if from_unit == to_unit
    val * scale_unit_from_kwh(to_unit, fuel_type, meter_collection) / scale_unit_from_kwh(from_unit, fuel_type, meter_collection)
  end

  def scale_unit_from_kwh(unit, fuel_type, meter_collection)
    return 1.0 if unit == :kwh

    if meter_collection.aggregate_meter(fuel_type).nil?
      # the benchmarking code for a school with storage heaters
      # benchmarks against gas tariffs, so if no gas then
      # default conversion to a constant rate
      ConvertKwh.scale_unit_from_kwh(unit, fuel_type)
    else
      puts Thread.current.backtrace
      puts "Chart: Blending calc #{1.0 / one_year_blended_conversion_from_kwh(unit, fuel_type, meter_collection)}"
      one_year_blended_conversion_from_kwh(unit, fuel_type, meter_collection)
    end
  end

  def one_year_blended_conversion_from_kwh(to_unit, fuel_type, meter_collection)
    aggregate_meter = meter_collection.aggregate_meter(fuel_type)
    aggregate_meter.amr_data.blended_rate(:kwh, to_unit)
  end
end
