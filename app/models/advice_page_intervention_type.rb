class AdvicePageInterventionType < ApplicationRecord
  belongs_to :advice_page
  belongs_to :intervention_type

  validates :intervention_type, :advice_page, presence: true
end
