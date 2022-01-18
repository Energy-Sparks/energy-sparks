require 'rails_helper'

describe Schools::ManagementTableService do

  let!(:school)       { create(:school) }
  let!(:service)      { Schools::ManagementTableService.new(school) }

  context 'when calculating the management dashboard' do
    context 'and there is no ManagementDashboardTable' do
      it 'returns nil' do
        expect(service.management_table).to be_nil
      end
    end

    context 'and there is analytics data' do
      let!(:content_generation_run) { create(:content_generation_run, school: school)}

      let(:summary) {
        [
          ["", "Annual Use (kWh)", "Annual CO2 (kg)", "Annual Cost", "Change from last year", "Change in last 4 school weeks", "Potential savings"],
          ["Electricity", "730,000", "140,000", "£110,000", "+12%", "-8.5%", "£83,000"],
          ["Gas", "not enough data", "not enough data", "not enough data", "not enough data", "-50%", "not enough data"]
        ]
      }
      let(:table_data)  { { 'summary_table' => summary } }

      let!(:alert)     { create(:alert, table_data: table_data ) }
      let!(:management_dashboard_table) { create(:management_dashboard_table, content_generation_run: content_generation_run, alert: alert) }

      it 'returns the alert content' do
        expect(service.management_table).to eql summary
      end
    end
  end

end
