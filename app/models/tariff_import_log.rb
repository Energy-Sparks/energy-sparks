class TariffImportLog < ApplicationRecord
  has_many :tariff_prices, inverse_of: :tariff_import_log
  has_many :tariff_standing_charges, inverse_of: :tariff_import_log
  scope :errored,       -> { where.not(error_messages: nil) }
  scope :successful,    -> { where(error_messages: nil) }
end
