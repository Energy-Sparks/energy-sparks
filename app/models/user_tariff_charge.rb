# == Schema Information
#
# Table name: user_tariff_charges
#
#  charge_type    :text             not null
#  created_at     :datetime         not null
#  id             :bigint(8)        not null, primary key
#  units          :text             not null
#  updated_at     :datetime         not null
#  user_tariff_id :bigint(8)        not null
#  value          :decimal(, )      not null
#
# Indexes
#
#  index_user_tariff_charges_on_user_tariff_id  (user_tariff_id)
#
class UserTariffCharge < ApplicationRecord
  belongs_to :user_tariff, inverse_of: :user_tariff_charges

  validates :charge_type, :value, :units, presence: true

  CHARGE_TYPES = {
    duos_red: 'Duos red',
    duos_amber: 'Duos amber',
    duos_green: 'Duos green',
    fixed_charge: 'Fixed charge',
    agreed_availability_charge: 'Agreed availability charge',
    reactive_power_charge: 'Reactive power charge',
    settlement_agency_fee: 'Settlement agency fee',
    half_hourly_data_charge: 'Half hourly data charge',
    site_fee: 'Site fee',
  }.freeze

  CHARGE_TYPE_UNITS = {
    kwh: 'kWh',
    kva: 'kVA',
    day: 'day',
    month: 'month',
    quarter: 'quarter',
  }.freeze

  def self.charge_types
    CHARGE_TYPES.map {|k, v| [v, k]}
  end

  def self.charge_type_units
    CHARGE_TYPE_UNITS.map {|k, v| [v, k]}
  end
end
