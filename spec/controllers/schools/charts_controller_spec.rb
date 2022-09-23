require 'rails_helper'

RSpec.describe Schools::ChartsController, type: :controller do
  context 'GET #show' do
    describe "format json" do
      it 'returns a json error message if a chart type param is missing' do
        school = FactoryBot.create :school, visible: false
        get :show, params: { school_id: school.to_param }, format: :json
        expect(JSON.parse(response.body)).to eq({'error' => 'param is missing or the value is empty: chart_type','status' => 400})
      end
    end

    describe "format html" do
      it 'fails if a chart type param is missing' do
        school = FactoryBot.create :school, visible: false
        expect { get :show, params: { school_id: school.to_param }, format: :html }.to raise_error(ActionController::ParameterMissing)
      end
    end
  end
end