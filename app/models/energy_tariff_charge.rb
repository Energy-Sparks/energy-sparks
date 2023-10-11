# == Schema Information
#
# Table name: energy_tariff_charges
#
#  charge_type      :text             not null
#  created_at       :datetime         not null
#  energy_tariff_id :bigint(8)        not null
#  id               :bigint(8)        not null, primary key
#  units            :text
#  updated_at       :datetime         not null
#  value            :decimal(, )      not null
#
# Indexes
#
#  index_energy_tariff_charges_on_energy_tariff_id  (energy_tariff_id)
#
class EnergyTariffCharge < ApplicationRecord
  belongs_to :energy_tariff, inverse_of: :energy_tariff_charges

  validates :charge_type, :value, presence: true
  validates :value, numericality: { greater_than_or_equal_to: 0.0 }

  scope :for_type, ->(type) { where(charge_type: type.to_s) }

  def self.charge_type_units
    {
      kwh: I18n.t('charge_type_units.kwh'),
      kva: I18n.t('charge_type_units.kva'),
      day: I18n.t('charge_type_units.day'),
      month: I18n.t('charge_type_units.month'),
      quarter: I18n.t('charge_type_units.quarter')
    }.freeze
  end

  def self.charge_types
    {
      standing_charge: {
        units: %i[day month quarter],
        name: I18n.t('user_tariff_charge.standing_charge')
      },
      asc_limit_kw: {
        units: [],
        label: 'kVA',
        name: I18n.t('user_tariff_charge.available_capacity')
      },
      renewable_energy_obligation: {
        units: [:kwh],
        name: I18n.t('user_tariff_charge.renewable_energy_obligation')
      },
      feed_in_tariff_levy: {
        units: [:kwh],
        name: I18n.t('user_tariff_charge.feed_in_tariff_levy')
      },
      agreed_capacity: {
        units: %i[day month quarter],
        name: I18n.t('user_tariff_charge.agreed_capacity')
      },
      agreed_availability_charge: {
        units: [:kva],
        tip: I18n.t('user_tariff_charge.available_capacity_tip'),
        name: I18n.t('user_tariff_charge.agreed_availability_charge')
      },
      excess_availability_charge: {
        units: [:kva],
        tip: I18n.t('user_tariff_charge.available_capacity_tip'),
        name: I18n.t('user_tariff_charge.excess_availability_charge')
      },
      settlement_agency_fee: {
        units: %i[day month quarter],
        name: I18n.t('user_tariff_charge.settlement_agency_fee')
      },
      reactive_power_charge: {
        units: [:kva],
        name: I18n.t('user_tariff_charge.reactive_power_charge')
      },
      half_hourly_data_charge: {
        units: %i[day month quarter],
        name: I18n.t('user_tariff_charge.half_hourly_data_charge')
      },
      fixed_charge: {
        units: %i[day month quarter],
        name: I18n.t('user_tariff_charge.fixed_charge')
      },
      nhh_metering_agent_charge: {
        units: %i[kwh day month quarter],
        name: I18n.t('user_tariff_charge.nhh_metering_agent_charge')
      },
      nhh_automatic_meter_reading_charge: {
        units: %i[kwh day month quarter],
        name: I18n.t('user_tariff_charge.nhh_automatic_meter_reading_charge')
      },
      meter_asset_provider_charge: {
        units: %i[day month quarter],
        name: I18n.t('user_tariff_charge.meter_asset_provider_charge')
      },
      data_collection_dcda_agent_charge: {
        units: %i[day month quarter],
        name: I18n.t('user_tariff_charge.data_collection_dcda_agent_charge')
      },
      site_fee: {
        units: %i[day month quarter],
        name: I18n.t('user_tariff_charge.site_fee')
      },
      duos_red: {
        units: [],
        name: I18n.t('user_tariff_charge.unit_rate_charge_red'),
        label: I18n.t('user_tariff_charge.rate')
      },
      duos_amber: {
        units: [],
        name: I18n.t('user_tariff_charge.unit_rate_charge_amber'),
        label: I18n.t('user_tariff_charge.rate')
      },
      duos_green: {
        units: [],
        name: I18n.t('user_tariff_charge.unit_rate_charge_green'),
        label: I18n.t('user_tariff_charge.rate')
      },
      other: {
        units: %i[kwh day month quarter],
        name: I18n.t('user_tariff_charge.other')
      }
    }.freeze
  end

  def is_type?(types)
    types.map(&:to_sym).include?(charge_type.to_sym)
  end
end
