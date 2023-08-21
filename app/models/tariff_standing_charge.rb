# == Schema Information
#
# Table name: tariff_standing_charges
#
#  created_at           :datetime         not null
#  id                   :bigint(8)        not null, primary key
#  meter_id             :bigint(8)
#  start_date           :date             not null
#  tariff_import_log_id :bigint(8)
#  updated_at           :datetime         not null
#  value                :decimal(, )      not null
#
# Indexes
#
#  index_tariff_standing_charges_on_meter_id                 (meter_id)
#  index_tariff_standing_charges_on_meter_id_and_start_date  (meter_id,start_date) UNIQUE
#  index_tariff_standing_charges_on_tariff_import_log_id     (tariff_import_log_id)
#
class TariffStandingCharge < ApplicationRecord
  scope :by_date,       -> { order(start_date: :asc) }
  scope :by_date_desc,  -> { order(start_date: :desc) }

  belongs_to :meter, inverse_of: :tariff_standing_charges
  belongs_to :tariff_import_log, inverse_of: :tariff_standing_charges

  attribute :value, :float

  def self.delete_duplicates_for_meter!(meter)
    last_charge = nil
    meter.tariff_standing_charges.order(start_date: :asc).each do |tariff_standing_charge|
      last_charge = tariff_standing_charge if last_charge.nil? || last_charge.value != tariff_standing_charge.value
      tariff_standing_charge.destroy if tariff_standing_charge != last_charge && tariff_standing_charge.value == last_charge.value
    end
  end
end
