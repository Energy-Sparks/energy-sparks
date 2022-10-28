class SchoolAlternativeHeatingSource < ApplicationRecord
  belongs_to :school, inverse_of: :alternative_heating_sources
end
