# == Schema Information
#
# Table name: user_tariffs
#
#  ccl        :boolean          default(FALSE)
#  created_at :datetime         not null
#  end_date   :date             not null
#  flat_rate  :boolean          default(TRUE)
#  fuel_type  :text             not null
#  id         :bigint(8)        not null, primary key
#  name       :text             not null
#  school_id  :bigint(8)        not null
#  start_date :date             not null
#  updated_at :datetime         not null
#  vat_rate   :string
#
# Indexes
#
#  index_user_tariffs_on_school_id  (school_id)
#
class UserTariff < ApplicationRecord
  belongs_to :school, inverse_of: :user_tariffs
  has_many :user_tariff_prices, inverse_of: :user_tariff
  has_many :user_tariff_charges, inverse_of: :user_tariff
  has_and_belongs_to_many :meters, inverse_of: :user_tariffs

  validates :name, :start_date, :end_date, presence: true

  scope :by_name, -> { order(name: :asc) }
  scope :electricity, -> { where(fuel_type: 'electricity') }
  scope :gas, -> { where(fuel_type: 'gas') }

  def electricity?
    fuel_type.to_sym == :electricity
  end

  def gas?
    fuel_type.to_sym == :gas
  end

  def meter_attribute
    MeterAttribute.new(attribute_type: :accounting_tariff_generic, input_data: to_hash)
  end

  def to_hash
    hsh = {
      start_date: start_date.to_s(:es_compact),
      end_date: end_date.to_s(:es_compact),
      source: :manually_entered,
      name: name,
      type: flat_rate ? :flat : :differential,
      sub_type: '',
      rates: rates,
    }
    # remove when 0% added to analytics
    if ['5%', '20%'].include?(vat_rate)
      hsh[:vat] = vat_rate
    end
    hsh
  end

  private

  def rates
    attrs = {}
    user_tariff_prices.each_with_index do |price, idx|
      attrs["rate#{idx}".to_sym] = { rate: price.value.to_s, per: price.units.to_s, from: hour_minutes(price.start_time), to: hour_minutes(price.end_time) }
    end
    user_tariff_charges.each do |charge|
      attrs[charge.charge_type.to_sym] = { rate: charge.value.to_s, per: charge.units.to_s }
    end
    attrs
  end

  def hour_minutes(time)
    hm = time.to_s(:time).split(':')
    {
      hour: hm.first,
      minutes: hm.last
    }
  end
end
