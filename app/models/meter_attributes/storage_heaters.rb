# frozen_string_literal: true

module MeterAttributes
  class StorageHeaters < MeterAttributeTypes::AttributeBase
    id :storage_heaters
    aggregate_over :storage_heaters
    name 'Storage heaters > Storage heater configuration'

    structure MeterAttributeTypes::Hash.define(
      structure: {
        start_date: MeterAttributeTypes::Date.define,
        end_date: MeterAttributeTypes::Date.define,
        power_kw: MeterAttributeTypes::Float.define,
        charge_start_time: MeterAttributeTypes::TimeOfDay.define,
        charge_end_time: MeterAttributeTypes::TimeOfDay.define
      }
    )
  end
end
