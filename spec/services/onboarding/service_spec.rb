require 'rails_helper'

describe Onboarding::Service, type: :service do
  let(:admin)         { create(:admin) }
  let(:school)        { create(:school, visible: false) }

  let!(:onboarding) do
    create(
      :school_onboarding,
      school: school,
      created_by: admin
    )
  end

  let(:confirmed_user)    { create(:user) }
  let(:unconfirmed_user)  { create(:user, confirmed_at: nil) }

  let(:school_user_1) { create(:user, school: school) }
  let(:school_user_2) { create(:user, school: school) }

  subject { Onboarding::Service.new }

  context '#should_complete_onboarding?' do
    it 'true if onboarding not complete yet' do
      expect(subject.should_complete_onboarding?(school)).to be_truthy
    end
    it 'false if onboarding complete already' do
      subject.record_event(onboarding, :onboarding_complete)
      expect(subject.should_complete_onboarding?(school)).to be_falsey
    end
  end

  context '#record_event' do
    it 'executes block and returns result as well as recording event' do
      result = subject.record_event(onboarding, :email_sent) { 42 }
      expect(result).to eq(42)
      expect(onboarding.has_event?(:email_sent)).to be_truthy
    end
  end

  context '#complete_onboarding' do
    it 'records event' do
      subject.complete_onboarding(onboarding, [])
      expect(onboarding.has_event?(:onboarding_complete)).to be_truthy
    end
    it 'sets school visible if feature flag set' do
      subject.complete_onboarding(onboarding, [])
      expect(onboarding.school.visible?).to be_truthy
    end
    it 'sends confirmation email to unconfirmed users only' do
      expect(confirmed_user).not_to receive(:send_confirmation_instructions)
      expect(unconfirmed_user).to receive(:send_confirmation_instructions)
      subject.complete_onboarding(onboarding, [confirmed_user, unconfirmed_user])
    end
    it 'enrols in default program' do
      expect_any_instance_of(Programmes::Enroller).to receive(:enrol).with(school)
      subject.complete_onboarding(onboarding, [])
    end
    it 'broadcasts message' do
      expect do
        subject.complete_onboarding(onboarding, [])
      end.to broadcast(:onboarding_completed, onboarding)
    end
  end
end
