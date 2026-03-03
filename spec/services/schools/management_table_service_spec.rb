require 'rails_helper'

describe Schools::ManagementTableService do
  let!(:school)       { create(:school) }
  let!(:service)      { Schools::ManagementTableService.new(school) }

  context 'when calculating the management dashboard' do
    context 'and there is no ManagementDashboardTable' do
      it 'returns nil' do
        expect(service.management_data).to be_nil
      end
    end

    context 'and there is analytics data' do
      let!(:content_generation_run) { create(:content_generation_run, school: school)}

      let(:variables) { { 'summary_data' => { gas: { start_date: '2020-01-01', end_date: '2020-02-01' } } } }

      let!(:alert) { create(:alert, variables: variables) }
      let!(:management_dashboard_table) { create(:management_dashboard_table, content_generation_run: content_generation_run, alert: alert) }

      it 'returns the alert content' do
        expect(service.management_data.start_date(:gas)).to eq('1 Jan 2020')
        expect(service.management_data.end_date(:gas)).to eq('1 Feb 2020')
      end
    end
  end
end
