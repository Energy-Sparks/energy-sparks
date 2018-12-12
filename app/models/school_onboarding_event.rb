# == Schema Information
#
# Table name: school_onboarding_events
#
#  created_at           :datetime         not null
#  event                :integer          not null
#  id                   :bigint(8)        not null, primary key
#  school_onboarding_id :bigint(8)        not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_school_onboarding_events_on_school_onboarding_id  (school_onboarding_id)
#
# Foreign Keys
#
#  fk_rails_...  (school_onboarding_id => school_onboardings.id) ON DELETE => cascade
#

class SchoolOnboardingEvent < ApplicationRecord
  belongs_to :school_onboarding

  enum event: { email_sent: 0 }
end
