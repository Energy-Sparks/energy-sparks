# frozen_string_literal: true

# == Schema Information
#
# Table name: energy_tariffs_meters
#
#  energy_tariff_id :bigint(8)
#  meter_id         :bigint(8)
#
# Indexes
#
#  index_energy_tariffs_meters_on_energy_tariff_id  (energy_tariff_id)
#  index_energy_tariffs_meters_on_meter_id          (meter_id)
#
class EnergyTariffsMeter < ApplicationRecord
  belongs_to :meter
  belongs_to :energy_tariff
end
