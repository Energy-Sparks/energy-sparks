require 'rails_helper'

module Alerts
  describe GenerateAndSaveBenchmarks do
    let!(:school)                 { create(:school) }
    let(:aggregate_school)        { double(:aggregate_school) }
    let(:asof_date)               { Date.parse('01/01/2019') }
    let(:alert_type)              { create(:alert_type, fuel_type: nil, frequency: :weekly, source: :analytics) }
    let(:framework_adapter)       { double :framework_adapter }
    let(:adapter_instance)        { double :adapter_instance }

    let(:alert_report_attributes) {{
      valid: true,
      rating: 5.0,
      enough_data: :enough,
      relevance: :relevant,
      template_data: {template: 'benchmark'},
      chart_data: {chart: 'variables'},
      table_data: {table: 'variables'},
      priority_data: {priority: 'variables'},
      benchmark_data: {benchmark: 'variables'}
    }}

    let(:example_benchmark_report)    { Adapters::Report.new(alert_report_attributes) }

    let(:example_no_benchmark_alert_report) do
      benchmark_alert_report_attributes = alert_report_attributes.clone
      benchmark_alert_report_attributes[:benchmark_data] = {}
      benchmark_alert_report_attributes[:template_data] = { template: 'no benchmark'}
      Adapters::Report.new(benchmark_alert_report_attributes)
    end

    let(:example_invalid_report) do
      invalid_alert_report_attributes = alert_report_attributes.clone
      invalid_alert_report_attributes[:valid] = false
      invalid_alert_report_attributes[:template_data] = { template: 'invalid'}
      Adapters::Report.new(invalid_alert_report_attributes)
    end

    let(:error_messages) { ["Broken"] }

    let(:alert_type_run_result) do
      AlertTypeRunResult.new(alert_type: alert_type, reports: [example_benchmark_report, example_no_benchmark_alert_report, example_invalid_report], asof_date: asof_date )
    end

    let(:alert_type_run_result_just_errors) do
      AlertTypeRunResult.new(alert_type: alert_type, reports: [], error_messages: error_messages, asof_date: asof_date)
    end

    before(:each) do
      allow_any_instance_of(AggregateSchoolService).to receive(:aggregate_school).and_return(school)
      allow(framework_adapter).to receive(:new).with(alert_type: alert_type, school: school, aggregate_school: aggregate_school, analysis_date: nil).and_return(adapter_instance)
      allow(adapter_instance).to receive(:benchmark_dates).and_return([asof_date, asof_date - 1.year])
    end

    describe '#perform' do
      it 'handles empty results' do
        allow_any_instance_of(GenerateAlertTypeRunResult).to receive(:perform).and_return(AlertTypeRunResult.new(alert_type: alert_type, asof_date: asof_date))

        service = GenerateAndSaveBenchmarks.new(school: school, aggregate_school: aggregate_school)
        expect { service.perform }.to change { BenchmarkResult.count }.by(0).and change { BenchmarkResultError.count }.by(0)
      end

      it 'handles just benchmark reports' do
        allow_any_instance_of(GenerateAlertTypeRunResult).to receive(:perform).and_return(alert_type_run_result)

        service = GenerateAndSaveBenchmarks.new(school: school, aggregate_school: aggregate_school)
        expect { service.perform }.to change { BenchmarkResult.count }.by(2).and change { BenchmarkResultError.count }.by(2)
      end

      it 'handles just errors' do
        allow_any_instance_of(GenerateAlertTypeRunResult).to receive(:perform).and_return(alert_type_run_result_just_errors)

        service = GenerateAndSaveBenchmarks.new(school: school, aggregate_school: aggregate_school)
        expect { service.perform }.to change { BenchmarkResult.count }.by(0).and  change { BenchmarkResultError.count }.by(2)
      end
    end
  end
end
