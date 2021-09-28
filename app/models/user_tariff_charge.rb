# == Schema Information
#
# Table name: user_tariff_charges
#
#  charge_type    :text             not null
#  created_at     :datetime         not null
#  id             :bigint(8)        not null, primary key
#  units          :text
#  updated_at     :datetime         not null
#  user_tariff_id :bigint(8)        not null
#  value          :decimal(, )      not null
#
# Indexes
#
#  index_user_tariff_charges_on_user_tariff_id  (user_tariff_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_tariff_id => user_tariffs.id) ON DELETE => cascade
#
class UserTariffCharge < ApplicationRecord
  belongs_to :user_tariff, inverse_of: :user_tariff_charges

  validates :charge_type, :value, presence: true
  validates :value, numericality: true

  scope :for_type, ->(type) { where('charge_type = ?', type.to_s) }

  CHARGE_TYPES = {
    standing_charge: {
      units: [:day, :month, :quarter]
    },
    asc_limit_kw: {
      units: [],
      label: 'kVA',
      name: 'Available capacity'
    },
    renewable_energy_obligation: {
      units: [:kwh]
    },
    feed_in_tariff_levy: {
      units: [:kwh]
    },
    agreed_capacity: {
      units: [:day, :month, :quarter]
    },
    agreed_availability_charge: {
      units: [:kva]
    },
    excess_availability_charge: {
      units: [:kva]
    },
    settlement_agency_fee: {
      units: [:day, :month, :quarter]
    },
    reactive_power_charge: {
      units: [:kva]
    },
    half_hourly_data_charge: {
      units: [:day, :month, :quarter]
    },
    fixed_charge: {
      units: [:day, :month, :quarter]
    },
    nhh_metering_agent_charge: {
      units: [:kwh, :day, :month, :quarter],
      name: 'NHH metering agent charge'
    },
    nhh_automatic_meter_reading_charge: {
      units: [:kwh, :day, :month, :quarter],
      name: 'NHH automatic meter reading charge'
    },
    meter_asset_provider_charge: {
      units: [:day, :month, :quarter]
    },
    data_collection_dcda_agent_charge: {
      units: [:day, :month, :quarter],
      name: 'Data Collection DC/DA Agent Charge'
    },
    site_fee: {
      units: [:day, :month, :quarter]
    },
    duos_red: {
      units: [],
      name: 'Unit rate charge (red)',
      label: 'Rate'
    },
    duos_amber: {
      units: [],
      name: 'Unit rate charge (amber)',
      label: 'Rate'
    },
    duos_green: {
      units: [],
      name: 'Unit rate charge (green)',
      label: 'Rate'
    },
    other: {
      units: [:kwh, :day, :month, :quarter]
    },
  }.freeze

  CHARGE_TYPE_UNITS = {
    kwh: 'kWh',
    kva: 'kVA',
    day: 'day',
    month: 'month',
    quarter: 'quarter',
  }.freeze

  def is_type?(types)
    types.map(&:to_sym).include?(charge_type.to_sym)
  end
end
