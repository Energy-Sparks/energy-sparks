require 'rails_helper'

describe Alerts::GenerateAndSaveAlerts do

  let(:framework_adapter) { double :framework_adapter }
  let(:adapter_instance)  { double :adapter_instance }
  let(:aggregate_school)  { double :aggregate_school }
  let(:school)            { create(:school) }

  describe '#perform' do

    let(:alert_type)              { create(:alert_type, fuel_type: nil, frequency: :weekly, source: :analytics) }
    let(:alert_report_attributes) {{
      valid: true,
      rating: 5.0,
      enough_data: :enough,
      relevance: :relevant,
      template_data: {template: 'variables'},
      chart_data: {chart: 'variables'},
      table_data: {table: 'variables'},
      priority_data: {priority: 'variables'},
      benchmark_data: {benchmark: 'variables'}
    }}
    let(:alert_report) { Alerts::Adapters::Report.new(alert_report_attributes) }

    describe 'error handling' do
      it 'does not raise an error if the framework_adapter raises one' do
        expect(framework_adapter).to receive(:new).with(alert_type: alert_type, school: school, aggregate_school: aggregate_school).and_return(adapter_instance)
        expect(adapter_instance).to receive(:analysis_date).and_return(Date.parse('01/01/2019'))
        expect(adapter_instance).to receive(:analyse).and_raise(ArgumentError)

        service = Alerts::GenerateAndSaveAlerts.new(school: school, framework_adapter: framework_adapter, aggregate_school: aggregate_school)

        expect { service.perform }.to_not raise_error

        expect(AlertError.count).to be 1
        expect(AlertError.first.alert_type).to eq alert_type
        expect(Alert.count).to be 0
        expect(BenchmarkResult.count).to be 0
      end
    end

    it 'working normally it saves alert with benchmark' do
      expect(framework_adapter).to receive(:new).with(alert_type: alert_type, school: school, aggregate_school: aggregate_school).and_return(adapter_instance)
      expect(adapter_instance).to receive(:analysis_date).and_return(Date.parse('01/01/2019'))
      expect(adapter_instance).to receive(:analyse).and_return alert_report

      service = Alerts::GenerateAndSaveAlerts.new(school: school, framework_adapter: framework_adapter, aggregate_school: aggregate_school)

      expect { service.perform }.to change { Alert.count }.by(1).and change { BenchmarkResult.count }.by(1).and change { AlertError.count }.by(0)
    end

    it 'working normally it saves alert with out benchmark' do

      alert_report_attributes[:benchmark_data] = {}
      alert_report = Alerts::Adapters::Report.new(alert_report_attributes)

      expect(framework_adapter).to receive(:new).with(alert_type: alert_type, school: school, aggregate_school: aggregate_school).and_return(adapter_instance)
      expect(adapter_instance).to receive(:analysis_date).and_return(Date.parse('01/01/2019'))
      expect(adapter_instance).to receive(:analyse).and_return alert_report

      service = Alerts::GenerateAndSaveAlerts.new(school: school, framework_adapter: framework_adapter, aggregate_school: aggregate_school)

      expect { service.perform }.to change { Alert.count }.by(1).and change { BenchmarkResult.count }.by(0).and change { AlertError.count }.by(0)
    end



    it 'invalid alert it saves alert error' do
      invalid_attributes = alert_report_attributes
      invalid_attributes[:valid] = false

      alert_report = Alerts::Adapters::Report.new(invalid_attributes)

      expect(framework_adapter).to receive(:new).with(alert_type: alert_type, school: school, aggregate_school: aggregate_school).and_return(adapter_instance)
      expect(adapter_instance).to receive(:analysis_date).and_return(Date.parse('01/01/2019'))
      expect(adapter_instance).to receive(:analyse).and_return alert_report

      service = Alerts::GenerateAndSaveAlerts.new(school: school, framework_adapter: framework_adapter, aggregate_school: aggregate_school)

      expect { service.perform }.to change { AlertError.count }.by(1).and change { Alert.count }.by(0)
    end
  end

  describe '#relevant_alert_types' do
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
