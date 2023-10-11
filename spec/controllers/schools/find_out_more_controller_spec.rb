require 'rails_helper'

RSpec.describe Schools::FindOutMoreController, type: :controller do
  let(:school)    { create(:school) }
  let(:user)      { create(:staff, school: school) }

  let!(:alert_type_rating_content_version) do
    create(:alert_type_rating_content_version, alert_type_rating: alert_type_rating)
  end
  let!(:alert_type_rating) do
    create(
      :alert_type_rating,
      find_out_more_active: true
    )
  end
  let!(:alert) do
    create(:alert, :with_run,
           alert_type: alert_type_rating.alert_type,
           run_on: Time.zone.today, school: school,
           rating: 9.0)
  end

  before do
    Alerts::GenerateContent.new(school).perform
  end

  context 'for a guest' do
    it 'redirects the user' do
      get :show, params: { school_id: school.to_param, id: FindOutMore.first.to_param }
      expect(response).to redirect_to(school_advice_path(school))
    end
  end

  context 'for an admin user' do
    let(:user) { create(:admin) }

    before do
      sign_in(user)
    end

    it 'redirects the user' do
      get :show, params: { school_id: school.to_param, id: FindOutMore.first.to_param }
      expect(response).to redirect_to(school_advice_path(school))
    end
  end

  context 'for a staff user' do
    before do
      sign_in(user)
    end

    it 'redirects the user' do
      get :show, params: { school_id: school.to_param, id: FindOutMore.first.to_param }
      expect(response).to redirect_to(school_advice_path(school))
    end

    context 'and there is an advice page' do
      let(:advice_page) { create(:advice_page, key: :baseload) }

      before do
        alert_type_rating.alert_type.update(advice_page: advice_page)
      end

      it 'redirects to the page' do
        get :show, params: { school_id: school.to_param, id: FindOutMore.first.to_param }
        expect(response).to redirect_to(insights_school_advice_baseload_path(school))
      end
    end
  end
end
