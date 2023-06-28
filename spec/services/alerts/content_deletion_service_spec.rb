require 'rails_helper'

describe Alerts::ContentDeletionService, type: :service do
  let!(:school) { create(:school) }
  let(:service) { Alerts::DeleteAlertGenerationRunService.new }
  let(:alert_type_description) { 'all about this alert type' }
  let(:gas_fuel_alert_type)             { create(:alert_type, fuel_type: :gas, frequency: :termly, description: alert_type_description) }
  let(:electricity_fuel_alert_type)     { create(:alert_type, fuel_type: :electricity, frequency: :termly, description: alert_type_description) }

  it 'defaults to beginning of month, 3 months ago' do
    expect(service.older_than).to eql(1.months.ago.beginning_of_month)
  end

  it 'calls delete!' do
    # Note: there are specific specs with full test coverage for each of these classes in the spec/services/alerts folder
    allow_any_instance_of(Alerts::DeleteContentGenerationRunService).to receive(:delete!) { true }
    allow_any_instance_of(Alerts::DeleteBenchmarkRunService).to receive(:delete!) { true }
    allow_any_instance_of(Alerts::DeleteAlertGenerationRunService).to receive(:delete!) { true }
    expect(service.delete!).to eq(true)
  end
end
