# powering tv for a period
# driving a car for a distance
# number of showers lasting 8 minutes
#
# Usage:
#   equivalence = EnergyEquivalences.new(10000000000.0, :kwh)
#   pounds       = equlivalece.value(:£)
#   car_distance = equlivalece.value(:ice_car_distance_km)
#   car_distance, units, description = equlivalece.verbose_value(:car_distance_km)
#
# research:
# https://www.epa.gov/energy/greenhouse-gas-equivalencies-calculator but wrong grid carbon
# 1000 kWh = 90,000 smartphones charged
#          = 27 incancescent bulbs switched to LED
#          = 12 tree seedlings grown for 10 years
# BBC
#         driving a car X miles
#         heating the average home for X days
#         litres of shower water = X 8 minute showers
# https://en.wikipedia.org/wiki/Carbon_footprint
#         flights, cars, trucks, rail, sea, cement
# other ideas:
#         cycling
#          homes, gas, electricity, tvs, tumbler dryers, washing machines, school dinners, lifetime emissions
#         recycling boxes of recycling (B&NES), jam sandwiches, laptop for X years
# Carbon trust
#         http://www.knowlton.org.uk/wp-content/files/Energy%20carbon%20conversions.pdf
#         different sized cars, airplanes, rail
#
class EnergyEquivalences
  attr_reader :kwh_deprecated, :fuel_type_deprecated
  def initialize_deprecated(value, units, fuel_type, grid_intensity)
    @fuel_type = fuel_type
    @kwh = EnergyEquivalences.conversion_ratio(value, units, fuel_type, :kwh, fuel_type, units, grid_intensity)
  end

  def self.conversion_ratio_deprecated(value, from_unit, from_type, to_unit, to_type, via_unit, grid_intensity)
    ratio, _from_desc, _to_desc = convert(value, from_unit, from_type, to_unit, to_type, via_unit, grid_intensity)
    ratio
  end

  def self.convert(value, from_unit, from_type, to_unit, to_type, via_unit)
    # ap( ENERGY_EQUIVALENCES2)
    check_got_co2_kwh_or_£(via_unit)
    from_unit_conversion, from_conversion_description, from_type_description =
      equivalence_conversion_rate_and_description(from_type, via_unit)
    to_unit_conversion, to_conversion_description, to_type_description =
      equivalence_conversion_rate_and_description(to_type, via_unit)

    equivalent = value * from_unit_conversion / to_unit_conversion

    equivalence = equivalence_description(value, from_unit, from_type_description, equivalent, to_unit, to_type_description)

    calc = calculation_description(value, from_unit, from_unit_conversion, to_unit_conversion, equivalent, to_unit, via_unit)

    [equivalent, equivalence, calc, from_conversion_description, to_conversion_description]
  end

  def self.equivalence_description(from_value, from_unit, from_type_description, to_value, to_unit, to_type_description)
    equivalence = # commented out following CT request 27Mar2019; description(from_value, from_unit, from_type_description) +
                  'This saving is equivalent to ' +
                  description(to_value, to_unit, to_type_description)
  end

  def self.calculation_description(from_value, from_unit, from_unit_conversion, to_unit_conversion, to_value, to_unit, via_unit)
    "Therefore " +
    "#{FormatEnergyUnit.format(from_unit, from_value)} " +
    (from_unit_conversion == 1.0 ? '' : " &times; #{FormatEnergyUnit.format(via_unit, from_unit_conversion)}/#{from_unit}") +
    " &divide; #{FormatEnergyUnit.format(via_unit, to_unit_conversion)}/#{to_unit.to_s.humanize} "\
    "= #{FormatEnergyUnit.format(to_unit, to_value)} "\
  end

  def self.description(value, unit, description)
    description % FormatEnergyUnit.format(unit, value)
  end

  def self.random_equivalence_type_and_via_type
    random_type = equivalence_types(false)[rand(equivalence_types(false).length)]
    equivalence = equivalence_configuration(random_type)
    random_via_type = equivalence[:conversions].keys[rand(equivalence[:conversions].length)]
    [random_type, random_via_type]
  end

  def self.equivalence_conversion_rate_and_description(type, via_unit)
    type = :electricity if type == :storage_heaters || type == :solar_pv
    type_data = equivalence_configuration(type)
    type_description = type_data[:description]
    rate = type_data[:conversions][via_unit][:rate]
    description = type_data[:conversions][via_unit][:description]
    [rate, description, type_description]
  end

  def self.check_got_co2_kwh_or_£(unit)
    raise EnergySparksUnexpectedStateException.new('Unexpected nil unit for conversion from electricity or gas') if unit.nil?
    unless [:kwh, :co2, :£].include?(unit)
      raise EnergySparksUnexpectedStateException.new("Unexpected unit #{unit} for conversion from electricity or gas")
    end
  end

  private

  def value_units(value, units) # should be moved to seperate class
    case units
    when :kwh
      sprintf('%6.0f kWh', value)
    when :£
      sprintf('£%6.0f', value)
    when :ice_car_distance_km, :bev_car_distance_km
      sprintf('%6.1fkm', value)
    else
      unknown_type(units)
    end
  end
end
