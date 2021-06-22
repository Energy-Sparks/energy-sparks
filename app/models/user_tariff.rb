# == Schema Information
#
# Table name: user_tariffs
#
#  created_at :datetime         not null
#  end_date   :date             not null
#  flat_rate  :boolean          default(TRUE)
#  fuel_type  :text             not null
#  id         :bigint(8)        not null, primary key
#  name       :text             not null
#  school_id  :bigint(8)        not null
#  start_date :date             not null
#  updated_at :datetime         not null
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

  def electricity?
    fuel_type.to_sym == :electricity
  end

  def gas?
    fuel_type.to_sym == :gas
  end

  def to_json(*_args)
    {
      "start_date" => start_date.to_s(:es_compact),
      "end_date" => end_date.to_s(:es_compact),
      "source" => "manually_entered",
      "name" => name,
      "type" => "differential",
      "sub_type" => "",
      "vat" => "5%",
      "rates" => rates,
    }.to_json
  end

  private

  def rates
    attrs = {}
    user_tariff_prices.each_with_index do |price, idx|
      attrs["rate#{idx}"] = { "rate" => price.value.to_s, "per" => price.units.to_s, "from" => hours_mins(price.start_time), "to" => hours_mins(price.end_time) }
    end
    user_tariff_charges.each do |charge|
      attrs[charge.charge_type.to_s] = { "rate" => charge.value.to_s, "per" => charge.units.to_s }
    end
    attrs
  end

  def hours_mins(time_str)
    parts = time_str.split(":")
    { "hour" => shorten(parts.first), "minutes" => shorten(parts.second) }
  end

  def shorten(str)
    str.to_i.to_s
  end
end
