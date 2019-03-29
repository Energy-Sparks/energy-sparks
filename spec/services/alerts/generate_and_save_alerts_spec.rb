require 'rails_helper'

describe Alerts::GenerateAndSaveAlerts do

  describe '#perform' do
    let(:framework_adapter){ double :framework_adapter }
    let(:adapter_instance){ double :adapter_instance }
    let(:school){ create(:school) }
    let(:alert_type){ create(:alert_type, fuel_type: nil, frequency: :weekly) }

    describe 'error handling' do
      it 'does not raise an error if the framework_adapter raises one' do
        expect(framework_adapter).to receive(:new).with(alert_type, school).and_return(adapter_instance)
        expect(adapter_instance).to receive(:analyse).and_raise(ArgumentError)

        expect{
          Alerts::GenerateAndSaveAlerts.new(school, framework_adapter).weekly_alerts
        }.to_not raise_error
      end
    end
  end

end
