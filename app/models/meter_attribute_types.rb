# frozen_string_literal: true

require 'date'
require 'active_support/core_ext/class/attribute'
require 'json'

module MeterAttributeTypes
  PSEUDO_METER_TYPES = [
    :aggregated_electricity,
    :aggregated_gas,
    :solar_pv_consumed_sub_meter,
    :solar_pv_exported_sub_meter,
    :solar_pv_original_sub_meter,
    :storage_heater_aggregated,
    :storage_heater_disaggregated_electricity,
    :storage_heater_disaggregated_storage_heater,
    :school_level_data,
  ].freeze
end
