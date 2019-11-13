require 'rails_helper'

describe Alerts::GenerateAndSaveAlertsAndBenchmarks do

  let!(:school)                 { create(:school) }
  let(:aggregate_school)        { double(:aggregate_school) }
  let(:asof_date)               { Date.parse('01/01/2019') }
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
    alert_type: alert_type,
    asof_date: asof_date
  }}

  let(:alert_report)            { Alerts::Adapters::Report.new(alert_report_attributes) }

  let(:example_alert_report)    { Alerts::Adapters::Report.new(alert_report_attributes) }
  let(:example_benchmark_alert_report) do
    benchmark_alert_report_attributes = alert_report_attributes.clone
    benchmark_alert_report_attributes[:benchmark_data] = {}
    Alerts::Adapters::Report.new(benchmark_alert_report_attributes)
  end

  let(:example_invalid_report) do
    invalid_alert_report_attributes = alert_report_attributes.clone
    invalid_alert_report_attributes[:valid] = false
    Alerts::Adapters::Report.new(invalid_alert_report_attributes)
  end

  let(:alert_reports)           { [example_alert_report, example_benchmark_alert_report, example_invalid_report] }


  describe '#perform' do
    it '#perform' do
      expect_any_instance_of(Alerts::GenerateAlertReports).to receive(:perform).and_return(alert_reports)
      allow_any_instance_of(AggregateSchoolService).to receive(:aggregate_school).and_return(school)

      service = Alerts::GenerateAndSaveAlertsAndBenchmarks.new(school: school, aggregate_school: aggregate_school)
      expect { service.perform }.to change { Alert.count }.by(2).and change { BenchmarkResult.count }.by(1).and change { AlertError.count }.by(1)
    end
  end
end
