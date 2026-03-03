# frozen_string_literal: true

require 'rails_helper'

module Alerts
  describe GenerateAndSaveAlertsAndBenchmarks do
    let!(:school) { create(:school, :with_fuel_configuration, has_gas: false) }
    let(:aggregate_school) do
      holidays = build(:holidays, :with_calendar_year)
      build(:meter_collection, :with_aggregated_aggregate_meter,
            holidays: holidays,
            start_date: Date.new(holidays.last.start_date.year, 1, 1),
            end_date: holidays.last.end_date)
    end
    let(:asof_date) { Date.parse('01/01/2019') }
    let(:alert_type) { create(:alert_type, fuel_type: nil, frequency: :weekly, source: :analytics) }
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
                             reports: [example_alert_report, example_benchmark_alert_report, example_invalid_report],
                             asof_date: asof_date)
    end

    let(:alert_type_run_result_just_errors) do
      AlertTypeRunResult.new(alert_type: alert_type, reports: [example_invalid_report], asof_date: asof_date)
    end

    before do
      allow_any_instance_of(AggregateSchoolService).to receive(:aggregate_school).and_return(school)
      create(:alert_type, class_name: AlertConfigurablePeriodElectricityComparison.name, fuel_type: :electricity)
      create(:alert_type, class_name: AlertConfigurablePeriodGasComparison.name)
      create(:alert_type, class_name: AlertConfigurablePeriodStorageHeaterComparison.name, fuel_type: :storage_heater)
    end

    describe '#perform' do
      it 'handles empty results' do
        expect_any_instance_of(GenerateAlertTypeRunResult).to receive(:perform).and_return(AlertTypeRunResult.new(
                                                                                             alert_type: alert_type, asof_date: asof_date
                                                                                           ))

        service = described_class.new(school: school, aggregate_school: aggregate_school)
        expect { service.perform }.not_to change(Alert, :count) &&
                                          change(AlertError, :count)
      end

      [[AlertSchoolWeekComparisonElectricity, :last_2_weeks],
       [ManagementSummaryTable, :last_12_months], # ContentBase type alert
       [AlertElectricityUsageDuringCurrentHoliday, :current_holidays],
       [AlertPreviousHolidayComparisonElectricity, :last_2_holidays]].each do |alert_class, period|
        it "sets reporting_period with #{alert_class}" do
          travel_to aggregate_school.holidays.last.start_date if period == :current_holidays
          create(:alert_type, class_name: alert_class.name, fuel_type: :electricity)
          service = described_class.new(school: school, aggregate_school: aggregate_school)
          expect { service.perform }.to change(Alert, :count).by(1)
          expect(Alert.last.reporting_period).to eq(period.to_s)
        end
      end

      it 'handles just alert reports' do
        alert_type.update!(benchmark: false)
        expect_any_instance_of(GenerateAlertTypeRunResult).to receive(:perform).and_return(alert_type_run_result)

        service = described_class.new(school: school, aggregate_school: aggregate_school)
        expect { service.perform }.to change(Alert, :count).by(2) &&
                                      change(AlertError, :count).by(1)

        expect(Alert.first.run_on).not_to be_nil
        expect(Alert.first.template_data).not_to be_nil
        expect(Alert.first.template_data_cy).not_to be_nil
      end

      it 'handles just alert errors' do
        alert_type.update!(benchmark: false)
        expect_any_instance_of(GenerateAlertTypeRunResult).to receive(:perform).and_return(alert_type_run_result_just_errors)

        service = described_class.new(school: school, aggregate_school: aggregate_school)
        expect { service.perform }.to not_change(Alert, :count) &&
                                      change(AlertError, :count).by(1)
      end

      it 'handles alert and benchmark reports' do
        alert_type.update!(benchmark: true)
        expect_any_instance_of(GenerateAlertTypeRunResult).to receive(:perform).and_return(alert_type_run_result)

        service = described_class.new(school: school, aggregate_school: aggregate_school)
        expect { service.perform }.to change(Alert, :count).by(2) &&
                                      change(AlertError, :count).by(1)

        expect(Alert.first.run_on).not_to be_nil
        expect(Alert.first.template_data).not_to be_nil
        expect(Alert.first.template_data_cy).not_to be_nil
      end

      it 'handles alert and benchmark errors' do
        alert_type.update!(benchmark: true)
        expect_any_instance_of(GenerateAlertTypeRunResult).to receive(:perform)
          .and_return(alert_type_run_result_just_errors)

        service = described_class.new(school: school, aggregate_school: aggregate_school)
        expect { service.perform }.to not_change(Alert, :count) &&
                                      change(AlertError, :count).by(1)
      end

      it 'handles custom period reports' do
        travel_to(Date.new(2024, 12, 1))
        report = create(:report, :with_custom_period)
        report.custom_period.update(current_start_date: 1.day.ago,
                                    previous_end_date: 2.days.ago,
                                    previous_start_date: 3.days.ago)
        service = described_class.new(school: school, aggregate_school: aggregate_school)
        expect { service.perform }.to change(Alert, :count)
        alert = Alert.last
        expect(alert.enough_data).to eq('enough')
        expect(alert.alert_type.class_name).to eq('AlertConfigurablePeriodElectricityComparison')
        expect(alert.reporting_period).to eq('custom')
        expect(alert.comparison_report_id).to eq(report.id)
      end
    end
  end
end
