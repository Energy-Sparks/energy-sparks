require 'rails_helper'

module Alerts
  describe GenerateAndSaveAlerts do
    let!(:school)                 { create(:school) }
    let(:aggregate_school)        { double(:aggregate_school) }
    let(:asof_date)               { Date.parse('01/01/2019') }
    let(:alert_type)              { create(:alert_type, fuel_type: nil, frequency: :weekly, source: :analytics) }

    let(:alert_report_attributes) do
      {
        valid: true,
        rating: 5.0,
        enough_data: :enough,
        relevance: :relevant,
        template_data: { template: 'variables' },
        template_data_cy: { template: 'welsh variables' },
        chart_data: { chart: 'variables' },
        table_data: { table: 'variables' },
        priority_data: { priority: 'variables' },
        benchmark_data: { benchmark: 'variables' }
      }
    end

    let(:alert_report)            { Adapters::Report.new(**alert_report_attributes) }

    let(:example_alert_report)    { Adapters::Report.new(**alert_report_attributes) }
    let(:example_benchmark_alert_report) do
      benchmark_alert_report_attributes = alert_report_attributes.clone
      benchmark_alert_report_attributes[:benchmark_data] = {}
      Adapters::Report.new(**benchmark_alert_report_attributes)
    end

    let(:example_invalid_report) do
      invalid_alert_report_attributes = alert_report_attributes.clone
      invalid_alert_report_attributes[:valid] = false
      Adapters::Report.new(**invalid_alert_report_attributes)
    end

    let(:error_messages) { ['Broken'] }

    let(:alert_type_run_result) do
      AlertTypeRunResult.new(alert_type: alert_type, reports: [example_alert_report, example_benchmark_alert_report, example_invalid_report], asof_date: asof_date)
    end

    let(:alert_type_run_result_just_errors) do
      AlertTypeRunResult.new(alert_type: alert_type, reports: [], error_messages: error_messages, asof_date: asof_date)
    end

    before do
      allow_any_instance_of(AggregateSchoolService).to receive(:aggregate_school).and_return(school)
    end

    describe '#perform' do
      it 'handles empty results' do
        expect_any_instance_of(GenerateAlertTypeRunResult).to receive(:perform).and_return(AlertTypeRunResult.new(alert_type: alert_type, asof_date: asof_date))

        service = GenerateAndSaveAlerts.new(school: school, aggregate_school: aggregate_school)
        expect { service.perform }.to change(Alert, :count).by(0).and change(AlertError, :count).by(0)
      end

      it 'handles just alert reports' do
        expect_any_instance_of(GenerateAlertTypeRunResult).to receive(:perform).and_return(alert_type_run_result)

        service = GenerateAndSaveAlerts.new(school: school, aggregate_school: aggregate_school)
        expect { service.perform }.to change(Alert, :count).by(2).and change(AlertError, :count).by(1)
        expect(Alert.first.run_on).not_to be_nil
        expect(Alert.first.template_data).not_to be_nil
        expect(Alert.first.template_data_cy).not_to be_nil
      end

      it 'handles just errors' do
        expect_any_instance_of(GenerateAlertTypeRunResult).to receive(:perform).and_return(alert_type_run_result_just_errors)

        service = GenerateAndSaveAlerts.new(school: school, aggregate_school: aggregate_school)
        expect { service.perform }.to change(Alert, :count).by(0).and change(AlertError, :count).by(1)
      end
    end
  end
end
