class TariffStandingCharge < ApplicationRecord
  belongs_to :meter, inverse_of: :tariff_standing_charges
  belongs_to :tariff_import_log, inverse_of: :tariff_standing_charges
end
