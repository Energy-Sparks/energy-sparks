require 'rails_helper'

RSpec.describe Onboarding::ConsentController, type: :controller do

  let!(:onboarding) do
    create(:school_onboarding)
  end

  describe '#show' do

    it 'renders the show template' do
      get :show, params: {onboarding_id: onboarding.to_param}
      expect(response).to render_template("show")
    end

    context 'when the onboarding is complete' do
      let!(:onboarding) do
        create(:school_onboarding, :with_events, event_names: [:permission_given])
      end
      it 'redirects to the next step' do
        get :show, params: {onboarding_id: onboarding.to_param}
        expect(response).to redirect_to(new_onboarding_account_path(onboarding))
      end
    end
  end

end
