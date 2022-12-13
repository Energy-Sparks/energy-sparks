require 'rails_helper'

RSpec.describe OnboardingMailer do
  let(:school_onboarding) { create(:school_onboarding, school_name: 'Test School') }

  describe '#onboarding_email' do
    it 'sends the onboarding email' do
      OnboardingMailer.with(emails: ['test@blah.com'], school_onboarding: school_onboarding).onboarding_email.deliver_now
      email = ActionMailer::Base.deliveries.last
      expect(email.subject).to eq("Set up your school on Energy Sparks")
      expect(email.body.to_s).to include("Thank you for enrolling Test School onto the Energy Sparks programme (www.energysparks.uk).")
    end
  end

  describe '#completion_email' do
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
