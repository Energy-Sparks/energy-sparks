# frozen_string_literal: true

module MeterAttributes
  class ModelledSolarPvGeneration < MeterAttributeTypes::AttributeBase
    id :modelled_solar_pv_generation
    aggregate_over :modelled_solar_pv_generation
    name 'Solar > Modelled Solar PV Generation'
    description 'Supplemental modelled generation for metered solar'

    structure MeterAttributeTypes::Hash.define(
      structure: {
        start_date: MeterAttributeTypes::Date.define,
        end_date: MeterAttributeTypes::Date.define,
        kwp: MeterAttributeTypes::Float.define
      }
    )
  end
end
