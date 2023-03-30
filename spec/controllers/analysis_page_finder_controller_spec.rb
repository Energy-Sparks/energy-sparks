require 'rails_helper'

RSpec.describe AnalysisPageFinderController, type: :controller do

  around do |example|
    ClimateControl.modify FEATURE_FLAG_REPLACE_ANALYSIS_PAGES: feature_flag do
      example.run
    end
  end

  describe 'GET #show' do

    context 'when redirecting to advice pages' do

      let(:feature_flag) { 'true' }
      let(:school) { create(:school, urn: 'abc123') }
      let(:advice_page) { create(:advice_page, key: 'baseload') }
      let!(:alert_type) { create(:alert_type, class_name: 'SomeAlertType', advice_page: advice_page) }

      it 'finds the advice page' do
        params = {urn: school.urn, analysis_class: 'SomeAlertType'}
        get :show, params: params
        expect(response).to redirect_to("http://test.host/schools/#{school.slug}/advice/#{advice_page.key}/insights")
      end

      it 'handles unknown alert type and redirects to advice index' do
        params = {urn: school.urn, analysis_class: 'BogusAlertType'}
        get :show, params: params
        expect(response).to redirect_to("http://test.host/schools/#{school.slug}/advice")
      end

    end
  end
end
