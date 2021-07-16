require 'rails_helper'

RSpec.describe Admin::SchoolOnboardings::ReminderController, type: :controller do

  let(:admin) { create(:admin) }
  let!(:onboarding) { create :school_onboarding, :with_events }

  before do
    sign_in(admin)
  end

  describe '#create' do
    it 'redirects to url with anchor' do
      post :create, params: {school_onboarding_id: onboarding.uuid, school_group: 'some-group-name-anchor'}
      expect(response).to redirect_to(admin_school_onboardings_path(anchor: 'some-group-name-anchor'))
      expect(onboarding.reload.events.map(&:event)).to include('reminder_sent')
    end
  end
end
