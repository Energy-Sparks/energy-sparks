require 'rails_helper'

module Alerts
  describe GenerateAndSaveAlertsAndBenchmarks do

    let!(:school)                 { create(:school) }
    let(:aggregate_school)        { double(:aggregate_school) }
    let(:asof_date)               { Date.parse('01/01/2019') }
    let!(:alert_type)              { create(:alert_type, fuel_type: nil, frequency: :weekly, source: :analytics) }

    let(:alert_report_attributes) {{
      valid: true,
      rating: 5.0,
      enough_data: :enough,
      relevance: :relevant,
      template_data: {template: 'variables'},
      chart_data: {chart: 'variables'},
      table_data: {table: 'variables'},
      priority_data: {priority: 'variables'},
      benchmark_data: {}
    }}

    let(:alert_report)            { Adapters::Report.new(alert_report_attributes) }

    let(:example_alert_report)    {Adapters::Report.new(alert_report_attributes) }
    let(:example_benchmark_alert_report) do
      benchmark_alert_report_attributes = alert_report_attributes.clone
      benchmark_alert_report_attributes[:benchmark_data] = { woof: 'meow'}
      Adapters::Report.new(benchmark_alert_report_attributes)
    end

    let(:example_invalid_report) do
      invalid_alert_report_attributes = alert_report_attributes.clone
      invalid_alert_report_attributes[:valid] = false
      Adapters::Report.new(invalid_alert_report_attributes)
    end

    let(:error_messages) { ["Broken"] }

    let(:alert_type_run_result) do
      AlertTypeRunResult.new(alert_type: alert_type, reports: [example_alert_report, example_benchmark_alert_report, example_invalid_report], asof_date: asof_date )
    end

    let(:alert_type_run_result_just_errors) do
      AlertTypeRunResult.new(alert_type: alert_type, reports: [], error_messages: error_messages, asof_date: asof_date)
    end

    before(:each) do
      allow_any_instance_of(AggregateSchoolService).to receive(:aggregate_school).and_return(school)
    end

    describe '#perform' do
      it 'handles empty results' do
        expect_any_instance_of(GenerateAlertReports).to receive(:perform).and_return([])

        service = GenerateAndSaveAlertsAndBenchmarks.new(school: school, aggregate_school: aggregate_school)
        expect { service.perform }.to change { Alert.count }.by(0).and change { BenchmarkResult.count }.by(0).and change { AlertError.count }.by(0)
      end

      it 'handles just alert reports' do
        expect_any_instance_of(GenerateAlertReports).to receive(:perform).and_return([alert_type_run_result])

        service = GenerateAndSaveAlertsAndBenchmarks.new(school: school, aggregate_school: aggregate_school)
        expect { service.perform }.to change { Alert.count }.by(2).and change { BenchmarkResult.count }.by(1).and change { AlertError.count }.by(1)
      end

      it 'handles just errors' do
        expect_any_instance_of(GenerateAlertReports).to receive(:perform).and_return([alert_type_run_result_just_errors])

        service = GenerateAndSaveAlertsAndBenchmarks.new(school: school, aggregate_school: aggregate_school)
        expect { service.perform }.to change { Alert.count }.by(0).and change { BenchmarkResult.count }.by(0).and change { AlertError.count }.by(1)
      end
    end

    describe '#perform_historic_benchmarks' do
      it 'handles just benchmark reports filtered by source' do
        generate_alert_reports_class = double(:generate_alert_reports)
        generate_alert_reports_instance = double(:generate_alert_reports_instance)

        expect(GenerateAlertReports).to receive(:new).with(alert_types: AlertType.analytics, school: school, aggregate_school: aggregate_school, asof_date: asof_date).and_return(generate_alert_reports_instance)
        expect(generate_alert_reports_instance).to receive(:perform).and_return([alert_type_run_result])

        service = GenerateAndSaveAlertsAndBenchmarks.new(school: school, aggregate_school: aggregate_school)

        expect { service.perform_benchmarks_only(asof_date) }.to change { Alert.count }.by(0).and change { BenchmarkResult.count }.by(1).and change { AlertError.count }.by(1)
      end
    end
  end
end
