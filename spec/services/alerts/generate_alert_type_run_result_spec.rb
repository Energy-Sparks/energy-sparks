require 'rails_helper'

module Alerts
  describe GenerateAlertTypeRunResult do

    let(:framework_adapter)       { double :framework_adapter }
    let(:adapter_instance)        { double :adapter_instance }
    let(:aggregate_school)        { double :aggregate_school }
    let!(:school)                   { create(:school) }
    let(:asof_date)                 { Date.parse('01/01/2019') }

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

      let(:alert_report) { Adapters::Report.new(alert_report_attributes) }

      before(:each) do
        expect(framework_adapter).to receive(:new).with(alert_type: alert_type, school: school, aggregate_school: aggregate_school, asof_date: nil).and_return(adapter_instance)
        expect(adapter_instance).to receive(:analysis_date).and_return(asof_date)
      end

      describe 'error handling' do
        it 'does not raise an error if the framework_adapter raises one' do
          expect(adapter_instance).to receive(:analyse).and_raise(ArgumentError)

          service = GenerateAlertTypeRunResult.new(school: school, framework_adapter: framework_adapter, aggregate_school: aggregate_school, alert_type: alert_type, asof_date: nil)

          result = service.perform
          expect(result.error_messages).to_not be_empty
          expect(result.reports).to be_empty
        end
      end

      it 'working normally it returns alert report with benchmark' do
        expect(adapter_instance).to receive(:analyse).and_return alert_report

        service = GenerateAlertTypeRunResult.new(school: school, framework_adapter: framework_adapter, aggregate_school: aggregate_school, alert_type: alert_type, asof_date: nil)
        expect(service.perform.reports).to include(alert_report)
      end

      it 'working normally it returns alert report with out benchmark' do
        alert_report_attributes[:benchmark_data] = {}
        alert_report = Adapters::Report.new(alert_report_attributes)

        expect(adapter_instance).to receive(:analyse).and_return alert_report

        service = GenerateAlertTypeRunResult.new(school: school, framework_adapter: framework_adapter, aggregate_school: aggregate_school, alert_type: alert_type, asof_date: nil)
        expect(service.perform.reports).to include(alert_report)
      end

      it 'invalid alert' do
        invalid_attributes = alert_report_attributes
        invalid_attributes[:valid] = false

        alert_report = Adapters::Report.new(invalid_attributes)

        expect(adapter_instance).to receive(:analyse).and_return alert_report

        service = GenerateAlertTypeRunResult.new(school: school, framework_adapter: framework_adapter, aggregate_school: aggregate_school, alert_type: alert_type, asof_date: nil)

        expect(service.perform.reports).to include(alert_report)
      end
    end
  end
end
