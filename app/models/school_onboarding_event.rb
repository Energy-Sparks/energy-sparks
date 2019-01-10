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

  enum event: {
    email_sent: 0,
    permission_given: 10,
    onboarding_user_created: 20,
    school_admin_created: 30,
    default_school_times_added: 40,
    default_alerts_assigned: 50,
    school_calendar_created: 60,
    school_details_created: 70,
    onboarding_complete: 80,
    reminder_sent: 90
  }
end
