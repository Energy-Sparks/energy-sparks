require 'rails_helper'

describe Onboarding::Service, type: :service do

  let(:admin)       { create(:admin) }
  let(:school)      { create(:school, visible: false) }

  let(:onboarding) do
    create(
      :school_onboarding,
      school: school,
      created_by: admin
    )
  end

  let(:confirmed_user) { create(:user) }
  let(:unconfirmed_user) { create(:user, confirmed_at: nil) }

  let(:contact) { create(:contact_with_name_email_phone, school: school) }
  let(:user_with_contact) { create(:user, contacts: [contact]) }
  let(:user_without_contact) { create(:user, email: 'a@b.com') }

  let(:school_user_1) { create(:user, school: school) }
  let(:school_user_2) { create(:user, school: school) }

  subject { Onboarding::Service.new }

  context '#complete_onboarding' do
    it 'records event' do
      subject.complete_onboarding(onboarding, [])
      expect(onboarding.has_event?(:onboarding_complete)).to be_truthy
    end
    it 'sets school visible if feature flag set' do
      expect(EnergySparks::FeatureFlags).to receive(:active?).with(:data_enabled_onboarding).and_return(true)
      subject.complete_onboarding(onboarding, [])
      expect(onboarding.school.visible?).to be_truthy
    end
    it 'does not set school visible if feature flag not set' do
      expect(EnergySparks::FeatureFlags).to receive(:active?).with(:data_enabled_onboarding).and_return(false)
      subject.complete_onboarding(onboarding, [])
      expect(onboarding.school.visible?).to be_falsey
    end
    it 'sends confirmation email to unconfirmed users only' do
      expect(confirmed_user).not_to receive(:send_confirmation_instructions)
      expect(unconfirmed_user).to receive(:send_confirmation_instructions)
      subject.complete_onboarding(onboarding, [confirmed_user, unconfirmed_user])
    end
    it 'creates contacts unless they already exist' do
      subject.complete_onboarding(onboarding, [user_with_contact, user_without_contact])
      expect(onboarding.has_event?(:alert_contact_created)).to be_truthy
      expect(user_without_contact.contacts.count).to eq(1)
      expect(onboarding.school.contacts.last.user).to eq(user_without_contact)
    end
    it 'subscribes users to newsletters if user requested subscription' do
      expect_any_instance_of(MailchimpSubscriber).to receive(:subscribe).with(onboarding.school, school_user_2)
      onboarding.subscribe_users_to_newsletter = [school_user_2.id]
      subject.complete_onboarding(onboarding, [])
    end
    it 'enrols in default program' do
      expect_any_instance_of(Programmes::Enroller).to receive(:enrol).with(school)
      subject.complete_onboarding(onboarding, [])
    end
    it 'broadcasts message' do
      expect{
        subject.complete_onboarding(onboarding, [])
      }.to broadcast(:onboarding_completed, onboarding)
    end
  end
end
