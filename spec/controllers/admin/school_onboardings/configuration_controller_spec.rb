require 'rails_helper'

RSpec.describe Admin::SchoolOnboardings::ConfigurationController, type: :controller do

  let(:admin)             { create(:admin) }
  let(:school_group)      { create :school_group, name: 'My Super Group' }
  let(:expected_anchor)   { 'my-super-group' }
  let(:template_calendar) { create(:regional_calendar, :with_terms, title: 'BANES calendar') }

  let(:onboarding)        { create :school_onboarding, :with_events, event_names: [:email_sent], school_group: school_group }

  before do
    sign_in(admin)
  end

  describe '#update' do
    it 'redirects to url with anchor' do
      post :update, params: { school_onboarding_id: onboarding.uuid, school_onboarding: { :template_calendar_id => template_calendar.id } }
      expect(response).to redirect_to(admin_school_onboardings_path(anchor: expected_anchor))
    end
  end
end
