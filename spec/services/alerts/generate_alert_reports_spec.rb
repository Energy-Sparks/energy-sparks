require 'rails_helper'

describe Alerts::GenerateAlertReports do

  let(:framework_adapter)       { double :framework_adapter }
  let(:adapter_instance)        { double :adapter_instance }
  let(:aggregate_school)        { double :aggregate_school }
  let!(:school)                 { create(:school) }
  let(:asof_date)               { Date.parse('01/01/2019') }
  let(:alert_generation_run)    { AlertGenerationRun.create(school: school) }

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
      benchmark_data: {benchmark: 'variables'},
      asof_date: asof_date
    }}
    let(:alert_report) { Alerts::Adapters::Report.new(alert_report_attributes) }

    describe 'error handling' do
      it 'does not raise an error if the framework_adapter raises one' do
        expect(framework_adapter).to receive(:new).with(alert_type: alert_type, school: school, aggregate_school: aggregate_school).and_return(adapter_instance)
        expect(adapter_instance).to receive(:analysis_date).and_return(asof_date)
        expect(adapter_instance).to receive(:analyse).and_raise(ArgumentError)

        service = Alerts::GenerateAlertReports.new(school: school, framework_adapter: framework_adapter, aggregate_school: aggregate_school)

        result = service.perform.first
        expect(result.error_attributes).to_not be_empty
        expect(result.reports).to be_empty
      end
    end

    it 'working normally it returns alert report with benchmark' do
      expect(framework_adapter).to receive(:new).with(alert_type: alert_type, school: school, aggregate_school: aggregate_school).and_return(adapter_instance)
      expect(adapter_instance).to receive(:analysis_date).and_return(Date.parse('01/01/2019'))
      expect(adapter_instance).to receive(:analyse).and_return alert_report

      service = Alerts::GenerateAlertReports.new(school: school, framework_adapter: framework_adapter, aggregate_school: aggregate_school)

      expect(service.perform.first.reports).to include(alert_report)
    end

    it 'working normally it returns alert report with out benchmark' do
      alert_report_attributes[:benchmark_data] = {}
      alert_report = Alerts::Adapters::Report.new(alert_report_attributes)

      expect(framework_adapter).to receive(:new).with(alert_type: alert_type, school: school, aggregate_school: aggregate_school).and_return(adapter_instance)
      expect(adapter_instance).to receive(:analysis_date).and_return(Date.parse('01/01/2019'))
      expect(adapter_instance).to receive(:analyse).and_return alert_report

      service = Alerts::GenerateAlertReports.new(school: school, framework_adapter: framework_adapter, aggregate_school: aggregate_school)
      expect(service.perform.first.reports).to include(alert_report)
    end

    it 'invalid alert' do
      invalid_attributes = alert_report_attributes
      invalid_attributes[:valid] = false

      alert_report = Alerts::Adapters::Report.new(invalid_attributes)

      expect(framework_adapter).to receive(:new).with(alert_type: alert_type, school: school, aggregate_school: aggregate_school).and_return(adapter_instance)
      expect(adapter_instance).to receive(:analysis_date).and_return(Date.parse('01/01/2019'))
      expect(adapter_instance).to receive(:analyse).and_return alert_report

      service = Alerts::GenerateAlertReports.new(school: school, framework_adapter: framework_adapter, aggregate_school: aggregate_school)

      expect(service.perform.first.reports).to include(alert_report)
    end
  end
end
