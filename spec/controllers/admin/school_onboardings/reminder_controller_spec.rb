require 'rails_helper'

RSpec.describe Admin::SchoolOnboardings::ReminderController, type: :controller do

  let(:admin)             { create(:admin) }
  let(:school_group)      { create :school_group, name: 'My Super Group' }
  let(:expected_anchor)   { 'my-super-group' }

  let(:onboarding)        { create :school_onboarding, :with_events, event_names: [:email_sent], school_group: school_group }

  before do
    sign_in(admin)
  end

  describe '#create' do
    it 'redirects to url with anchor' do
      post :create, params: {school_onboarding_id: onboarding.uuid}
      expect(response).to redirect_to(admin_school_onboardings_path(anchor: expected_anchor))
      expect(onboarding.reload.events.map(&:event)).to include('reminder_sent')
    end
  end
end
