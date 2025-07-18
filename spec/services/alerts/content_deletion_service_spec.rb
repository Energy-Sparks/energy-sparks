require 'rails_helper'

describe Alerts::ContentDeletionService, type: :service do
  let!(:school) { create(:school) }
  let(:service) { Alerts::DeleteAlertGenerationRunService.new }
  let(:alert_type_description) { 'all about this alert type' }
  let(:gas_fuel_alert_type)             { create(:alert_type, fuel_type: :gas, frequency: :termly, description: alert_type_description) }
  let(:electricity_fuel_alert_type)     { create(:alert_type, fuel_type: :electricity, frequency: :termly, description: alert_type_description) }

  it 'defaults to 14 days ago' do
    expect(service.older_than).to eql(14.days.ago.to_date)
  end

  it 'calls delete!' do
    # Note: there are specific specs with full test coverage for each of these classes in the spec/services/alerts folder
    allow_any_instance_of(Alerts::DeleteContentGenerationRunService).to receive(:delete!).and_return(true)
    allow_any_instance_of(Alerts::DeleteAlertGenerationRunService).to receive(:delete!).and_return(true)
    expect(service.delete!).to eq(true)
  end
end
