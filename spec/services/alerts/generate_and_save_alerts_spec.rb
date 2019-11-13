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

    describe 'knows which alerts are relevant' do
      let!(:no_fuel_alert_type)          { create(:alert_type, fuel_type: nil) }
      let!(:electricity_alert_type)      { create(:alert_type, fuel_type: :electricity) }
      let!(:gas_alert_type)              { create(:alert_type, fuel_type: :gas) }
      let!(:storage_heater_alert_type)   { create(:alert_type, fuel_type: :storage_heater) }
      let!(:solar_pv_alert_type)         { create(:alert_type, fuel_type: :solar_pv) }

      let(:school)                      { create(:school) }

      it 'returns electricity and gas ones' do
        fuel_configuration = Schools::FuelConfiguration.new(has_gas: true, has_electricity: true)
        school.configuration.update(fuel_configuration: fuel_configuration)

        service = Alerts::GenerateAndSaveAlerts.new(school: school, framework_adapter: framework_adapter, aggregate_school: aggregate_school)
        expect(service.relevant_alert_types).to include(no_fuel_alert_type, electricity_alert_type, gas_alert_type)
        expect(service.relevant_alert_types).to_not include(storage_heater_alert_type, solar_pv_alert_type)
      end

      it 'returns storage heater and electricity' do
        fuel_configuration = Schools::FuelConfiguration.new(has_gas: false, has_electricity: true, has_storage_heaters: true)
        school.configuration.update(fuel_configuration: fuel_configuration)

        service = Alerts::GenerateAndSaveAlerts.new(school: school, framework_adapter: framework_adapter, aggregate_school: aggregate_school)
        expect(service.relevant_alert_types).to include(no_fuel_alert_type, electricity_alert_type, storage_heater_alert_type)
        expect(service.relevant_alert_types).to_not include(gas_alert_type, solar_pv_alert_type)
      end

      it 'returns storage heater and electricity and solar pv' do
        fuel_configuration = Schools::FuelConfiguration.new(has_gas: false, has_electricity: true, has_storage_heaters: true, has_solar_pv: true)
        school.configuration.update(fuel_configuration: fuel_configuration)

        service = Alerts::GenerateAndSaveAlerts.new(school: school, framework_adapter: framework_adapter, aggregate_school: aggregate_school)
        expect(service.relevant_alert_types).to include(no_fuel_alert_type, electricity_alert_type, storage_heater_alert_type, solar_pv_alert_type)
        expect(service.relevant_alert_types).to_not include(gas_alert_type)
      end

      it 'returns gas and no fuel only' do
        fuel_configuration = Schools::FuelConfiguration.new(has_gas: true)
        school.configuration.update(fuel_configuration: fuel_configuration)

        service = Alerts::GenerateAndSaveAlerts.new(school: school, framework_adapter: framework_adapter, aggregate_school: aggregate_school)
        expect(service.relevant_alert_types).to include(gas_alert_type, no_fuel_alert_type)
        expect(service.relevant_alert_types).to_not include(electricity_alert_type, storage_heater_alert_type, solar_pv_alert_type)
      end
    end
  end
end
