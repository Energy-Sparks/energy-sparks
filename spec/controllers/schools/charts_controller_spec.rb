require 'rails_helper'

RSpec.describe Schools::ChartsController, type: :controller do
  context 'GET #show' do
    before { @school = FactoryBot.create :school, visible: false }

    describe "format json" do
      it 'returns a json error message with 400 bad request if a chart type param is missing' do
        get :show, params: { school_id: @school.to_param }, format: :json
        expect(JSON.parse(response.body)).to eq({ 'error' => 'param is missing or the value is empty: chart_type', 'status' => 400 })
      end

      it 'returns a json response if a chart type param is present' do
        get :show, params: { school_id: @school.to_param, chart_type: 'pupil_dashboard_group_by_week_electricity_kwh' }, format: :json
        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body)['title']).to eq('We do not have enough data to display this chart at the moment: Pupil_dashboard_group_by_week_electricity_kwh chart')
      end
    end

    describe "format html" do
      it 'fails if a chart type param is missing' do
        expect { get :show, params: { school_id: @school.to_param }, format: :html }.to raise_error(ActionController::ParameterMissing)
      end
    end
  end
end
