# == Schema Information
#
# Table name: consent_grants
#
#  id                   :bigint(8)        not null, primary key
#  guid                 :text
#  ip_address           :text
#  job_title            :text
#  name                 :text
#  school_name          :text
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  consent_statement_id :bigint(8)        not null
#  school_id            :bigint(8)        not null
#  user_id              :bigint(8)
#
# Indexes
#
#  index_consent_grants_on_consent_statement_id  (consent_statement_id)
#  index_consent_grants_on_school_id             (school_id)
#  index_consent_grants_on_user_id               (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (consent_statement_id => consent_statements.id)
#  fk_rails_...  (school_id => schools.id)
#  fk_rails_...  (user_id => users.id)
#
class ConsentGrant < ApplicationRecord
  belongs_to :user, inverse_of: :consent_grants
  belongs_to :school, inverse_of: :consent_grants
  belongs_to :consent_statement, inverse_of: :consent_grants

  validates :user, :school, :consent_statement, presence: true
  validates :guid, uniqueness: true

  scope :by_date, -> { order(created_at: :desc) }

  before_save :set_reference

  private

  def set_reference
    self.guid = SecureRandom.hex(8)
  end
end
