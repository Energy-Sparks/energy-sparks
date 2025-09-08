module Enums::FuelType
  extend ActiveSupport::Concern

  ENUM_FUEL_TYPES = {
    electricity: 0,
    gas: 1,
    storage_heater: 2,
    solar_pv: 3,
    multiple: 4 # e.g. for metrics that are for total usage
  }.freeze

  included do
    enum :fuel_type, ENUM_FUEL_TYPES

    scope :no_fuel, -> { where(fuel_type: nil) }
  end
end
