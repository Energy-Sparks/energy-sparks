class TariffPrice < ApplicationRecord
  belongs_to :meter, inverse_of: :tariff_prices
  belongs_to :tariff_import_log, inverse_of: :tariff_prices
end
