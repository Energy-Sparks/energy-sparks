class AlertTypeRatingInterventionType < ApplicationRecord
  belongs_to :intervention_type
  belongs_to :alert_type_rating
  validates :intervention_type, :alert_type_rating, presence: true
end
