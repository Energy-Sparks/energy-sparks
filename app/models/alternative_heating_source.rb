class AlternativeHeatingSource < ApplicationRecord
  belongs_to :school
  validates :source, presence: true
  validates :percent_of_overall_use, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }

  enum source: { oil: 0, propane_gas: 1, biomass: 2, district: 3 }
end
