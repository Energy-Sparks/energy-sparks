require 'rails_helper'

RSpec.describe Onboarding::CompletionController, type: :controller do

  let(:user){ create(:onboarding_user) }
  let!(:onboarding) do
    create(:school_onboarding, created_user: user)
  end
  let(:school){ build :school }

  before do
    SchoolCreator.new(school).onboard_school!(onboarding)
    sign_in(user)
  end

  describe '#show' do
    it 'renders show if the school is not visible' do
      school.update!(visible: false)
      get :show, params: {onboarding_id: onboarding.to_param}
      expect(response).to render_template("show")
    end
    it 'redirects to the school if it is active' do
      get :show, params: {onboarding_id: onboarding.to_param}
      expect(response).to redirect_to(school_path(school))
    end
  end

  describe '#new' do

    it 'renders the new template' do
      get :new, params: {onboarding_id: onboarding.to_param}
      expect(response).to render_template("new")
    end

    context 'when the onboarding is complete' do
      let!(:onboarding) do
        create(:school_onboarding, :with_events, event_names: [:onboarding_complete], created_user: user)
      end
      it 'redirects to the show action' do
        get :new, params: {onboarding_id: onboarding.to_param}
        expect(response).to redirect_to(onboarding_completion_path(onboarding))
      end
    end
  end

end
