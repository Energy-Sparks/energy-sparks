# frozen_string_literal: true

module MeterAttributes
  class SolarPVOverrides < SolarPV
    id :solar_pv_override
    aggregate_over :solar_pv_override
    name 'Solar > Override bad metered solar pv data'
    structure MeterAttributeTypes::Hash.define(
      structure: {
        start_date: MeterAttributeTypes::Date.define,
        end_date: MeterAttributeTypes::Date.define,
        kwp: MeterAttributeTypes::Float.define,
        orientation: MeterAttributeTypes::Integer.define(hint: 'in degrees'),
        tilt: MeterAttributeTypes::Integer.define,
        shading: MeterAttributeTypes::Integer.define,
        fit_£_per_kwh: MeterAttributeTypes::Float.define,
        override_generation: MeterAttributeTypes::Boolean.define(required: false,
                                                                 hint: 'Check this to override generation data'),
        override_export: MeterAttributeTypes::Boolean.define(required: false,
                                                             hint: 'Check this to override export data'),
        override_self_consume: MeterAttributeTypes::Boolean.define(required: false,
                                                                   hint: 'Check this to override self consumption data')
      }
    )

    # NB uses inherited attributes
  end
end
