# frozen_string_literal: true

module MeterAttributes
  class SolarPVMeterMapping < MeterAttributeTypes::AttributeBase
    id                  :solar_pv_mpan_meter_mapping
    aggregate_over      :solar_pv_mpan_meter_mapping
    name                'Solar > Solar PV MPAN Meter mapping'

    structure MeterAttributeTypes::Hash.define(
      structure: {
        start_date: MeterAttributeTypes::Date.define(required: true),
        end_date: MeterAttributeTypes::Date.define,
        export_mpan: MeterAttributeTypes::String.define,
        production_mpan: MeterAttributeTypes::String.define,
        self_consume_mpan: MeterAttributeTypes::String.define(hint: 'currently unsupported'),
        production_mpan2: MeterAttributeTypes::String.define(hint: 'for 2nd generation meter'),
        production_mpan3: MeterAttributeTypes::String.define(hint: 'for 3rd generation meter'),
        production_mpan4: MeterAttributeTypes::String.define(hint: 'for 4th generation meter'),
        production_mpan5: MeterAttributeTypes::String.define(hint: 'for 5th generation meter')
      }
    )
  end
end
