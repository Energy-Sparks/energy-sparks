# == Schema Information
#
# Table name: tariff_import_logs
#
#  created_at                :datetime         not null
#  description               :text
#  end_date                  :date
#  error_messages            :text
#  id                        :bigint(8)        not null, primary key
#  import_time               :datetime
#  prices_imported           :integer          default(0), not null
#  prices_updated            :integer          default(0), not null
#  source                    :text             not null
#  standing_charges_imported :integer          default(0), not null
#  standing_charges_updated  :integer          default(0), not null
#  start_date                :date
#  updated_at                :datetime         not null
#
class TariffImportLog < ApplicationRecord
  has_many :tariff_prices, inverse_of: :tariff_import_log
  has_many :tariff_standing_charges, inverse_of: :tariff_import_log
  scope :errored,       -> { where.not(error_messages: nil) }
  scope :successful,    -> { where(error_messages: nil) }
end
