# == Schema Information
#
# Table name: meter_reviews
#
#  consent_grant_id :bigint(8)        not null
#  created_at       :datetime         not null
#  id               :bigint(8)        not null, primary key
#  school_id        :bigint(8)        not null
#  updated_at       :datetime         not null
#  user_id          :bigint(8)        not null
#
# Indexes
#
#  index_meter_reviews_on_consent_grant_id  (consent_grant_id)
#  index_meter_reviews_on_school_id         (school_id)
#  index_meter_reviews_on_user_id           (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (consent_grant_id => consent_grants.id)
#  fk_rails_...  (school_id => schools.id)
#  fk_rails_...  (user_id => users.id)
#
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
