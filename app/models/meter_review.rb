class MeterReview < ApplicationRecord
  belongs_to :school
  belongs_to :user
  belongs_to :consent_grant

  has_many :meters
  has_and_belongs_to_many :consent_documents

  validates_presence_of :school, :user, :consent_grant

  before_destroy do |review|
    review.meters.clear
    review.consent_documents.clear
  end
end
