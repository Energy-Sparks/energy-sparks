class ConsentGrant < ApplicationRecord
  belongs_to :user, inverse_of: :consent_grants
  belongs_to :school, inverse_of: :consent_grants
  belongs_to :consent_statement, inverse_of: :consent_grants

  validates :user, :school, :consent_statement, presence: true

  scope :by_date, -> { order(created_at: :desc) }
end
