class InterventionTypeGroup < ApplicationRecord
  has_many :intervention_types

  validates :title, presence: true, uniqueness: true
end
