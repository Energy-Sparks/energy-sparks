require 'rails_helper'

describe Targets::GenerateProgressService do
  subject!(:service) { Targets::GenerateProgressService.new(school, aggregated_school) }

  let!(:school) { create(:school) }
  let!(:aggregated_school) { instance_double(MeterCollection) }
  let!(:school_target) { create(:school_target, school: school) }
  let(:fuel_configuration) { Schools::FuelConfiguration.new(has_electricity: true) }
  let(:school_target_fuel_types) { ['electricity'] }
  let!(:school_config) { create(:configuration, school:, fuel_configuration:, school_target_fuel_types:) }
  let(:months) { [Time.zone.today.last_month.beginning_of_month, Time.zone.today.beginning_of_month] }
  let(:fuel_type) { :electricity }
  let(:monthly_targets_kwh) { [10, 10] }
  let(:monthly_usage_kwh) { [10, 5] }
  let(:monthly_performance) { [-0.25, 0.35] }
  let(:cumulative_targets_kwh) { [10, 20] }
  let(:cumulative_usage_kwh) { [10, 15] }
  let(:cumulative_performance) { [-0.99, 0.99] }
  let(:partial_months) { [false, true] }
  let(:percentage_synthetic) { [0, 0] }

  let(:progress) do
    TargetsProgress.new(
      fuel_type: fuel_type,
      months: months,
      monthly_targets_kwh: monthly_targets_kwh,
      monthly_usage_kwh: monthly_usage_kwh,
      monthly_performance: monthly_performance,
      cumulative_targets_kwh: cumulative_targets_kwh,
      cumulative_usage_kwh: cumulative_usage_kwh,
      cumulative_performance: cumulative_performance,
      cumulative_performance_versus_synthetic_last_year: [],
      monthly_performance_versus_synthetic_last_year: [],
      partial_months: partial_months,
      percentage_synthetic: percentage_synthetic
    )
  end

  before do
    allow_any_instance_of(AggregateSchoolService).to receive(:aggregate_school).and_return(aggregated_school)
    allow(aggregated_school).to receive(:aggregate_meter).and_return(build(:meter))
  end

  describe '#cumulative_progress' do
    context 'and there is an error in the progress report generation' do
      before do
        allow_any_instance_of(TargetsService).to receive(:enough_data_to_set_target?).and_return(true)
        allow_any_instance_of(TargetsService).to receive(:target_meter_calculation_problem).and_return(nil)
        allow_any_instance_of(TargetsService).to receive(:progress).and_raise(StandardError.new('test requested'))
      end

      it 'returns nil' do
        expect(service.cumulative_progress(:electricity)).to be_nil
      end
    end

    context 'and there is an error in the pre-conditions' do
      before do
        allow_any_instance_of(TargetsService).to receive(:enough_data_to_set_target?).and_raise(StandardError.new('test requested'))
      end

      it 'returns nil' do
        expect(service.cumulative_progress(:electricity)).to be_nil
      end
    end

    context 'for a fuel type' do
      context 'and its not present' do
        let(:fuel_configuration) { Schools::FuelConfiguration.new(has_electricity: false) }

        it 'returns nil' do
          expect(service.cumulative_progress(:electricity)).to be_nil
        end
      end

      context 'and it is present' do
        before do
          allow_any_instance_of(TargetsService).to receive(:enough_data_to_set_target?).and_return(true)
          allow_any_instance_of(TargetsService).to receive(:target_meter_calculation_problem).and_return(nil)
          allow_any_instance_of(TargetsService).to receive(:progress).and_return(progress)
        end

        it 'returns the value' do
          expect(service.cumulative_progress(:electricity)).to be 0.99
        end
      end
    end

    context 'and the data is lagging, only slightly' do
      let(:months)                    do
        [Time.zone.today.last_month.beginning_of_month, Time.zone.today.prev_month.beginning_of_month]
      end

      before do
        allow_any_instance_of(TargetsService).to receive(:enough_data_to_set_target?).and_return(true)
        allow_any_instance_of(TargetsService).to receive(:target_meter_calculation_problem).and_return(nil)
        allow_any_instance_of(TargetsService).to receive(:progress).and_return(progress)
      end

      it 'returns the value' do
        expect(service.cumulative_progress(:electricity)).to be 0.99
      end
    end
  end

  describe '#current_monthly_target' do
    before do
      allow_any_instance_of(TargetsService).to receive(:enough_data_to_set_target?).and_return(true)
      allow_any_instance_of(TargetsService).to receive(:target_meter_calculation_problem).and_return(nil)
      allow_any_instance_of(TargetsService).to receive(:progress).and_return(progress)
    end

    it 'returns the right value' do
      expect(service.current_monthly_target(:electricity)).to be 20
    end

    context 'and the data is lagging, only slightly' do
      let(:months) { [Time.zone.today.last_month.beginning_of_month, Time.zone.today.prev_month.beginning_of_month] }

      before do
        allow_any_instance_of(TargetsService).to receive(:enough_data_to_set_target?).and_return(true)
        allow_any_instance_of(TargetsService).to receive(:target_meter_calculation_problem).and_return(nil)
        allow_any_instance_of(TargetsService).to receive(:progress).and_return(progress)
      end

      it 'returns the value' do
        expect(service.current_monthly_target(:electricity)).to be 20
      end
    end
  end

  describe '#current_monthly_usage' do
    before do
      allow_any_instance_of(TargetsService).to receive(:enough_data_to_set_target?).and_return(true)
      allow_any_instance_of(TargetsService).to receive(:target_meter_calculation_problem).and_return(nil)
      allow_any_instance_of(TargetsService).to receive(:progress).and_return(progress)
    end

    it 'returns the right value' do
      expect(service.current_monthly_usage(:electricity)).to be 15
    end

    context 'and the data is lagging, only slightly' do
      let(:months) { [Time.zone.today.last_month.beginning_of_month, Time.zone.today.prev_month.beginning_of_month] }

      before do
        allow_any_instance_of(TargetsService).to receive(:enough_data_to_set_target?).and_return(true)
        allow_any_instance_of(TargetsService).to receive(:progress).and_return(progress)
      end

      it 'returns the value' do
        expect(service.current_monthly_usage(:electricity)).to be 15
      end
    end
  end

  describe '#generate!' do
    it 'does nothing if school has no target' do
      SchoolTarget.all.destroy_all
      expect(service.generate!).to be_nil
    end

    context 'with only electricity fuel type' do
      before do
        allow_any_instance_of(TargetsService).to receive(:enough_data_to_set_target?).and_return(true)
        allow_any_instance_of(TargetsService).to receive(:target_meter_calculation_problem).and_return(nil)
        allow_any_instance_of(TargetsService).to receive(:progress).and_return(progress)
        allow_any_instance_of(TargetsService).to receive(:recent_data?).and_return(true)
      end

      let(:target) { service.generate! }

      it 'updates the target' do
        expect(target).to eql school_target
      end

      it 'saved the progress report' do
        expect(target.saved_progress_report_for(:electricity).to_json).to eq(progress.to_json)
      end

      it 'records when last run' do
        expect(target.report_last_generated).not_to be_nil
      end

      it 'includes only that fuel type' do
        expect(target.gas_progress).to eq({})
        expect(target.storage_heaters_progress).to eq({})
        expect(target.electricity_progress).not_to eq({})
      end

      it 'reports the fuel progress' do
        expect(target.electricity_progress['progress']).to be 0.99
        expect(target.electricity_progress['usage']).to be 15
        expect(target.electricity_progress['target']).to be 20
      end
    end

    context 'and not enough data' do
      let(:school_target_fuel_types) { [] }

      before do
        allow_any_instance_of(TargetsService).to receive(:enough_data_to_set_target?).and_return(true)
        allow_any_instance_of(TargetsService).to receive(:target_meter_calculation_problem).and_return(nil)
        allow_any_instance_of(TargetsService).to receive(:progress).and_return(progress)
        allow_any_instance_of(TargetsService).to receive(:recent_data?).and_return(true)
      end

      it 'still generates' do
        expect(service.generate!).to eq school_target
      end
    end

    context 'when there is an error in the progress report generation' do
      let(:target) { service.generate! }

      before do
        allow_any_instance_of(TargetsService).to receive(:enough_data_to_set_target?).and_return(true)
        allow_any_instance_of(TargetsService).to receive(:target_meter_calculation_problem).and_return(nil)
        allow_any_instance_of(TargetsService).to receive(:progress).and_raise(error)
      end

      context 'with a problem that should be logged' do
        let(:error) { StandardError.new('test requested') }

        it 'reports to rollbar' do
          expect(Rollbar).to receive(:error).with(error, scope: :generate_progress, school_id: school.id,
                                                         school: school.name, fuel_type: :electricity)
          target
        end

        it 'records when last run' do
          expect(target.report_last_generated).not_to be_nil
        end

        it 'sets values to nil' do
          expect(target.electricity_progress).to eq({})
          expect(target.electricity_report).to be_nil
        end
      end

      context 'with a problem that is just a warning' do
        let(:error) { TargetDates::TargetDateBeforeFirstMeterStartDate.new('can be ignored') }

        it 'does not report to rollbar' do
          expect(Rollbar).not_to receive(:error).with(error, scope: :generate_progress, school_id: school.id,
                                                             school: school.name, fuel_type: :electricity)
          target
        end

        it 'records when last run' do
          expect(target.report_last_generated).not_to be_nil
        end

        it 'sets values to nil' do
          expect(target.electricity_progress).to eq({})
          expect(target.electricity_report).to be_nil
        end
      end
    end

    context 'when looking at monthly consumption data' do
      let(:school_target) do
        create(:school_target, school:, electricity: 3,
                               start_date: Date.new(2024, 5, 1), target_date: Date.new(2025, 5, 1))
      end
      let(:target) { school_target }

      def run(end_date, period_length)
        meter_collection = build(:meter_collection, :with_aggregate_meter, start_date: end_date - period_length,
                                                                           end_date:,
                                                                           kwh_data_x48: Array.new(48, 1))
        described_class.new(school, meter_collection).generate!
        meter_collection
      end

      def expected_month_consumption(year)
        consumption = [[year, 5, 1488, 1488, 1443.36, false, false],
                       [year, 6, 1440, 1440, 1396.8, false, false],
                       [year, 7, 1488, 1488, 1443.36, false, false],
                       [year, 8, 1488, 1488, 1443.36, false, false],
                       [year, 9, 1440, 1440, 1396.8, false, false],
                       [year, 10, 1488, 1488, 1443.36, false, false],
                       [year, 11, 1440, 1440, 1396.8, false, false],
                       [year, 12, 1488, 1488, 1443.36, false, false],
                       [year + 1, 1, 1488, 1488, 1443.36, false, false],
                       [year + 1, 2, 1344, 1392, 1350.24, false, false],
                       [year + 1, 3, 1488, 1488, 1443.36, false, false],
                       [year + 1, 4, 1440, 1440, 1396.8, false, false]]
        consumption[9] = [2024, 2, 1392, 1344, 1303.68, false, false] if year == 2023
        consumption[11] = [2025, 4, 720, 1440, 1396.8, true, false] if year == 2024
        consumption
      end

      it 'returns consumption figures for each month of targets' do
        target2023 = create(:school_target, school:, electricity: 3,
                                            start_date: Date.new(2023, 5, 1), target_date: Date.new(2024, 5, 1))
        meter_collection = run(Date.new(2025, 4, 15), 3.years)
        expect(target2023.reload.electricity_monthly_consumption).to eq(expected_month_consumption(2023))
        expect(target.reload.electricity_monthly_consumption).to eq(expected_month_consumption(2024))
        expect { described_class.new(school, meter_collection).generate! }.to \
          change { target.reload.updated_at }.and(not_change { target2023.reload.updated_at })
      end

      it 'when data covers last month' do
        run(Date.new(2025, 5, 15), 2.years)
        target.reload
        expect(target.electricity_monthly_consumption.first).to eq([2024, 5, 1488, nil, nil, false, true])
        expect(target.electricity_monthly_consumption.last).to eq([2025, 4, 1440, 1440, 1396.8, false, false])
      end

      it 'with insufficient data' do
        run(Date.new(2025, 5, 15), 1.year)
        expect(target.reload.electricity_monthly_consumption).to eq([[2024, 5, 816, nil, nil, true, true],
                                                                     [2024, 6, 1440, nil, nil, false, true],
                                                                     [2024, 7, 1488, nil, nil, false, true],
                                                                     [2024, 8, 1488, nil, nil, false, true],
                                                                     [2024, 9, 1440, nil, nil, false, true],
                                                                     [2024, 10, 1488, nil, nil, false, true],
                                                                     [2024, 11, 1440, nil, nil, false, true],
                                                                     [2024, 12, 1488, nil, nil, false, true],
                                                                     [2025, 1, 1488, nil, nil, false, true],
                                                                     [2025, 2, 1344, nil, nil, false, true],
                                                                     [2025, 3, 1488, nil, nil, false, true],
                                                                     [2025, 4, 1440, nil, nil, false, true]])
      end

      it 'works with an incomplete month' do
        run(Date.new(2025, 3, 15), 2.years)
        expect(target.reload.electricity_monthly_consumption.last).to eq([2025, 4, nil, 1440, 1396.8, true, false])
      end
    end
  end
end
