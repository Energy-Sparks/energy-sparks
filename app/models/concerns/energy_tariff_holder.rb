# Should be included by classes that tariff holders
module EnergyTariffHolder
  extend ActiveSupport::Concern

  included do
    has_many :energy_tariffs, as: :tariff_holder, dependent: :destroy
  end

  def energy_tariff_meter_attributes(meter_type = EnergyTariff.meter_types.keys)
    energy_tariffs.where(meter_type: meter_type).complete.map(&:meter_attribute)
  end

  def parent_tariff_holder
    nil
  end

  def all_energy_tariff_attributes(meter_type = EnergyTariff.meter_types.keys)
    attributes = []
    parent = parent_tariff_holder
    attributes += parent.all_energy_tariff_attributes(meter_type) unless parent.nil?
    attributes += energy_tariff_meter_attributes(meter_type)
    attributes
  end
end
