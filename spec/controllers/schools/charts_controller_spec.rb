require 'rails_helper'

RSpec.describe Schools::ChartsController, type: :controller do
  context 'GET #show' do
    before { @school = FactoryBot.create :school, visible: false }

    describe 'format json' do
      it 'returns a json error message with 400 bad request if a chart type param is missing' do
        get :show, params: { school_id: @school.to_param }, format: :json
        expect(response.parsed_body).to include(
          'error' => start_with('param is missing or the value is empty: chart_type'),
          'status' => 400
        )
      end

      context 'with a chart type param' do
        context 'but we cannot run the chart' do
          let(:response) do
            get :show, params: { school_id: @school.to_param, chart_type: 'pupil_dashboard_group_by_week_electricity_kwh' }, format: :json
          end

          it 'still returns a json response' do
            expect(response).to have_http_status(:success)
            expect(JSON.parse(response.body)['title']).to eq('We do not have enough data to display this chart at the moment: Pupil_dashboard_group_by_week_electricity_kwh chart')
          end

          context 'when handling the error' do
            let(:admin)                  { false }
            let(:environment_identifier) { 'test' }

            around do |example|
              ClimateControl.modify ENVIRONMENT_IDENTIFIER: environment_identifier do
                example.run
              end
            end

            before do
              allow_any_instance_of(ChartManager).to receive(:run_chart).and_raise
              allow(controller).to receive(:current_user_admin?).and_return(admin)
            end

            context 'when not in production' do
              it 'reports to rollbar' do
                expect(Rollbar).to receive(:error)
                response
              end
            end

            context 'when in production' do
              let(:environment_identifier) { 'production' }

              before do
                allow(Rails).to receive(:env) { OpenStruct.new(production?: true) }
              end

              context 'with no admin user' do
                it 'reports to rollbar' do
                  expect(Rollbar).to receive(:error)
                  response
                end
              end

              context 'with admin user' do
                let(:admin) { true }

                it 'reports to rollbar' do
                  expect(Rollbar).not_to receive(:error)
                  response
                end
              end
            end
          end
        end
      end
    end
  end
end
