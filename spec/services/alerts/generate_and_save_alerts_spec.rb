require 'rails_helper'

describe Alerts::GenerateAndSaveAlerts do

  describe '#perform' do
    let(:framework_adapter) { double :framework_adapter }
    let(:adapter_instance)  { double :adapter_instance }
    let(:aggregate_school)  { double :aggregate_school }
    let(:school)            { create(:school) }
    let(:alert_type)        { create(:alert_type, fuel_type: nil, frequency: :weekly) }

    describe 'error handling' do
      it 'does not raise an error if the framework_adapter raises one' do
        expect(framework_adapter).to receive(:new).with(alert_type: alert_type, school: school, aggregate_school: aggregate_school).and_return(adapter_instance)
        expect(adapter_instance).to receive(:analysis_date).and_return(Date.parse('01/01/2019'))
        expect(adapter_instance).to receive(:analyse).and_raise(ArgumentError)

        expect{
          Alerts::GenerateAndSaveAlerts.new(school: school, framework_adapter: framework_adapter, aggregate_school: aggregate_school).perform
        }.to_not raise_error

        expect(AlertError.count).to be 1
        expect(AlertError.first.alert_type).to eq alert_type
      end
    end
  end
end
