require 'rails_helper'

describe SchoolOnboarding, type: :model do
  context 'knows when it has only done an email send and or reminder email' do
    it 'with an email sent' do
      onboarding = create :school_onboarding, :with_events, event_names: [:email_sent]
      expect(onboarding.has_only_sent_email_or_reminder?).to be true
    end

    it 'with an email and a reminder sent' do
      onboarding = create :school_onboarding, :with_events, event_names: [:email_sent, :reminder_sent]
      expect(onboarding.has_only_sent_email_or_reminder?).to be true
    end

    it 'or when it has not with extra events' do
      onboarding = create :school_onboarding, :with_events, event_names: [:email_sent, :reminder_sent, :school_admin_created]
      expect(onboarding.has_only_sent_email_or_reminder?).to be false
    end

    it 'knows when it is complete' do
      onboarding = create :school_onboarding, :with_events, event_names: [:onboarding_complete]
      expect(onboarding.incomplete?).to be false
    end

    it 'knows when it is incomplete' do
      onboarding = create :school_onboarding
      expect(onboarding.incomplete?).to be true
    end

  end
end
