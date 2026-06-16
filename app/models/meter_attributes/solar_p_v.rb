# frozen_string_literal: true

module MeterAttributes
  class SolarPV < MeterAttributeTypes::AttributeBase
    id :solar_pv
    aggregate_over :solar_pv
    name 'Solar > Solar PV'

    structure MeterAttributeTypes::Hash.define(
      structure: {
        start_date: MeterAttributeTypes::Date.define,
        end_date: MeterAttributeTypes::Date.define,
        kwp: MeterAttributeTypes::Float.define,
        orientation: MeterAttributeTypes::Integer.define(hint: 'in degrees'),
        tilt: MeterAttributeTypes::Integer.define,
        shading: MeterAttributeTypes::Integer.define,
        fit_£_per_kwh: MeterAttributeTypes::Float.define,
        maximum_export_level_kw: MeterAttributeTypes::Float.define
      }
    )
  end
end
