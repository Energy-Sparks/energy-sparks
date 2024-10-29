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

  scope :by_event_name, ->(event_name) { where(event: event_name).order(created_at: :asc) }

  enum :event, {
    email_sent: 0,
    privacy_policy_agreed: 9,
    permission_given: 10,
    onboarding_user_created: 20,
    onboarding_user_updated: 21,
    school_admin_created: 30,
    default_school_times_added: 40,
    default_alerts_assigned: 50,
    alert_contact_created: 51,
    school_calendar_created: 60,
    school_details_created: 70,
    school_details_updated: 71,
    pupil_account_created: 75,
    pupil_account_updated: 76,
    onboarding_complete: 80,
    onboarding_data_enabled: 81,
    reminder_sent: 90,
    activation_email_sent: 100,
    onboarded_email_sent: 101,
    data_enabled_email_sent: 102
  }
end
