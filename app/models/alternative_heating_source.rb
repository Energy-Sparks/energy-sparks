class AlternativeHeatingSource < ApplicationRecord
  belongs_to :school

  enum source: { oil: 0, propane_gas: 1, biomass: 2, district: 3 }
end
