# == Schema Information
#
# Table name: tariff_import_logs
#
#  id                        :bigint           not null, primary key
#  description               :text
#  end_date                  :date
#  error_messages            :text
#  import_time               :datetime
#  prices_imported           :integer          default(0), not null
#  prices_updated            :integer          default(0), not null
#  source                    :text             not null
#  standing_charges_imported :integer          default(0), not null
#  standing_charges_updated  :integer          default(0), not null
#  start_date                :date
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#
class TariffImportLog < ApplicationRecord
  has_many :tariff_prices, inverse_of: :tariff_import_log
  has_many :tariff_standing_charges, inverse_of: :tariff_import_log
  scope :errored,       -> { where.not(error_messages: nil) }
  scope :successful,    -> { where(error_messages: nil) }
  scope :by_import_time, -> { order(import_time: :desc) }
end
