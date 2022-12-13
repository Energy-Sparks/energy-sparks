require 'rails_helper'

RSpec.describe OnboardingMailer do
  let(:user){ create(:onboarding_user) }
  let(:school){ create(:school) }
  let(:school_onboarding) { create(:school_onboarding, school_name: 'Test School', created_by: user, school: school) }

  describe '#onboarding_email' do
    it 'sends the onboarding email' do
      OnboardingMailer.with(emails: ['test@blah.com'], school_onboarding: school_onboarding).onboarding_email.deliver_now
      email = ActionMailer::Base.deliveries.last
      expect(email.subject).to eq("Set up your school on Energy Sparks")
      I18n.t('onboarding_mailer.onboarding_email').except(:subject).values.each do |email_content|
        expect(email.body.to_s).to include(email_content.gsub('%{school_name}', 'Test School'))
      end
    end
  end

  describe '#completion_email' do
    it 'sends the completion email' do
      OnboardingMailer.with(emails: ['test@blah.com'], school_onboarding: school_onboarding).completion_email.deliver_now
      email = ActionMailer::Base.deliveries.last
      expect(email.subject).to eq("Test School has completed the onboarding process")
      I18n.t('onboarding_mailer.completion_email').except(:subject).values.each do |email_content|
        expect(email.body.to_s).to include(email_content.gsub('%{school_name}', 'Test School'))
      end
    end
  end

  describe '#reminder_email' do
  end

  describe '#activation_email' do
  end

  describe '#onboarded_email' do
  end

  describe '#data_enabled_email' do
  end

  describe '#welcome_email' do
  end
end
