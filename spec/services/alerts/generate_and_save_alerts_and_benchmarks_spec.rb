# frozen_string_literal: true

require 'rails_helper'

module Alerts
  describe GenerateAndSaveAlertsAndBenchmarks do
    let!(:school)                 { create(:school) }
    let(:aggregate_school)        { build(:meter_collection, :with_aggregate_meter) }
    let(:asof_date)               { Date.parse('01/01/2019') }
    let(:alert_type)              { create(:alert_type, fuel_type: nil, frequency: :weekly, source: :analytics) }
    let(:benchmark_result_generation_run) { BenchmarkResultGenerationRun.create! }

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
        benchmark_data: { benchmark: 'variables', var: Float::INFINITY },
        benchmark_data_cy: { benchmark: 'welsh-variables', var: Float::INFINITY }
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
      invalid_alert_report_attributes[:template_data] = { template: 'invalid' }
      Adapters::Report.new(**invalid_alert_report_attributes)
    end

    let(:error_messages) { ['Broken'] }

    let(:alert_type_run_result) do
      AlertTypeRunResult.new(alert_type: alert_type,
                             reports: [example_alert_report, example_benchmark_alert_report, example_invalid_report], asof_date: asof_date)
    end

    let(:alert_type_run_result_just_errors) do
      AlertTypeRunResult.new(alert_type: alert_type, reports: [example_invalid_report], asof_date: asof_date)
    end

    before do
      allow_any_instance_of(AggregateSchoolService).to receive(:aggregate_school).and_return(school)
    end

    describe '#perform' do
      it 'handles empty results' do
        expect_any_instance_of(GenerateAlertTypeRunResult).to receive(:perform).and_return(AlertTypeRunResult.new(
                                                                                             alert_type: alert_type, asof_date: asof_date
                                                                                           ))

        service = described_class.new(school: school, aggregate_school: aggregate_school)
        expect { service.perform }.not_to change(Alert, :count) &&
                                          change(AlertError, :count) &&
                                          change(BenchmarkResult, :count) &&
                                          change(BenchmarkResultError, :count)
      end

      it 'handles just alert reports' do
        alert_type.update!(benchmark: false)
        expect_any_instance_of(GenerateAlertTypeRunResult).to receive(:perform).and_return(alert_type_run_result)

        service = described_class.new(school: school, aggregate_school: aggregate_school)
        expect { service.perform }.to change(Alert, :count).by(2) &&
                                      change(AlertError, :count).by(1) &&
                                      not_change(BenchmarkResult, :count) &&
                                      not_change(BenchmarkResultError, :count)

        expect(Alert.first.run_on).not_to be_nil
        expect(Alert.first.template_data).not_to be_nil
        expect(Alert.first.template_data_cy).not_to be_nil
      end

      it 'handles just alert errors' do
        alert_type.update!(benchmark: false)
        expect_any_instance_of(GenerateAlertTypeRunResult).to receive(:perform).and_return(alert_type_run_result_just_errors)

        service = described_class.new(school: school, aggregate_school: aggregate_school)
        expect { service.perform }.to not_change(Alert, :count) &&
                                      change(AlertError, :count).by(1) &&
                                      not_change(BenchmarkResult, :count) &&
                                      not_change(BenchmarkResultError, :count)
      end

      it 'handles alert and benchmark reports' do
        alert_type.update!(benchmark: true)
        expect_any_instance_of(GenerateAlertTypeRunResult).to receive(:perform).and_return(alert_type_run_result)

        service = described_class.new(school: school, aggregate_school: aggregate_school)
        expect { service.perform }.to change(Alert, :count).by(2) &&
                                      change(AlertError, :count).by(1) &&
                                      change(BenchmarkResult, :count).by(2) &&
                                      change(BenchmarkResultError, :count).by(1)

        expect(Alert.first.run_on).not_to be_nil
        expect(Alert.first.template_data).not_to be_nil
        expect(Alert.first.template_data_cy).not_to be_nil

        expect(BenchmarkResult.last.results).not_to eq({})
        expect(BenchmarkResult.last.results_cy).not_to eq({})
        expect(BenchmarkResult.last.results['var']).to eq '.inf'
      end

      it 'handles alert and benchmark errors' do
        alert_type.update!(benchmark: true)
        expect_any_instance_of(GenerateAlertTypeRunResult).to receive(:perform).and_return(alert_type_run_result_just_errors)

        service = described_class.new(school: school, aggregate_school: aggregate_school)
        expect { service.perform }.to not_change(Alert, :count) &&
                                      change(AlertError, :count).by(1) &&
                                      not_change(BenchmarkResult, :count) &&
                                      change(BenchmarkResultError, :count).by(2) &&
                                      change(BenchmarkResultSchoolGenerationRun, :count).by(1)

        expect(BenchmarkResultSchoolGenerationRun.first.benchmark_result_error_count).to be 1
        expect(BenchmarkResultSchoolGenerationRun.first.benchmark_result_count).to be 0
      end

      it 'handles custom period reports' do
        school.configuration.update(fuel_configuration:
          school.configuration[:fuel_configuration].merge('has_electricity' => true))
        alert_type = create(:alert_type, class_name: 'AlertConfigurablePeriodElectricityComparison',
                                         fuel_type: :electricity)
        create(:alert_type, class_name: 'AlertConfigurablePeriodGasComparison')
        create(:alert_type, class_name: 'AlertConfigurablePeriodStorageHeaterComparison', fuel_type: :storage_heater)
        report = create(:report, :with_custom_period)
        report.custom_period.update(current_start_date: 1.day.ago,
                                    previous_end_date: 2.days.ago,
                                    previous_start_date: 3.days.ago)
        service = described_class.new(school: school, aggregate_school: aggregate_school)
        service.perform
        alert = Alert.last
        expect(alert.enough_data).to eq('enough')
        expect(alert.alert_type.class_name).to eq(alert_type.class_name)
        expect(alert.reporting_period).to eq('custom')
        expect(alert.custom_period_id).to eq(report.custom_period_id)
      end
    end
  end
end
