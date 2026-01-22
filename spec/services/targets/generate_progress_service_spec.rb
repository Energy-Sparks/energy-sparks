# frozen_string_literal: true

require 'rails_helper'

describe Targets::GenerateProgressService do
  subject!(:service) { described_class.new(school, aggregated_school) }

  let!(:school) { create(:school) }
  let!(:aggregated_school) { build(:meter_collection, :with_aggregate_meter) }
  let!(:school_target) { create(:school_target, school: school) }
  let(:fuel_configuration) { Schools::FuelConfiguration.new(has_electricity: true) }
  let(:school_target_fuel_types) { ['electricity'] }

  before { create(:configuration, school:, fuel_configuration:, school_target_fuel_types:) }

  describe '#generate!' do
    it 'does nothing if school has no target' do
      SchoolTarget.destroy_all
      expect(service.generate!).to be_nil
    end

    context 'with only electricity fuel type' do
      let(:target) { service.generate! }

      it 'updates the target' do
        expect(target).to eql school_target
      end

      it 'includes only that fuel type' do
        expect(target.gas_monthly_consumption).to be_nil
        expect(target.storage_heaters_monthly_consumption).to be_nil
        expect(target.electricity_monthly_consumption).not_to be_nil
      end
    end

    context 'and not enough data' do
      let(:school_target_fuel_types) { [] }

      it 'still generates' do
        expect(service.generate!).to eq school_target
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
        consumption = [[year, 5, 1488, 1488, 1443.36, false, false, false],
                       [year, 6, 1440, 1440, 1396.8, false, false, false],
                       [year, 7, 1488, 1488, 1443.36, false, false, false],
                       [year, 8, 1488, 1488, 1443.36, false, false, false],
                       [year, 9, 1440, 1440, 1396.8, false, false, false],
                       [year, 10, 1488, 1488, 1443.36, false, false, false],
                       [year, 11, 1440, 1440, 1396.8, false, false, false],
                       [year, 12, 1488, 1488, 1443.36, false, false, false],
                       [year + 1, 1, 1488, 1488, 1443.36, false, false, false],
                       [year + 1, 2, 1344, 1392, 1350.24, false, false, false],
                       [year + 1, 3, 1488, 1488, 1443.36, false, false, false],
                       [year + 1, 4, 1440, 1440, 1396.8, false, false, false]]
        consumption[9] = [2024, 2, 1392, 1344, 1303.68, false, false, false] if year == 2023
        consumption[11] = [2025, 4, 720, 1440, 1396.8, true, false, false] if year == 2024
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
        expect(target.electricity_monthly_consumption.first).to eq([2024, 5, 1488, nil, nil, false, true, false])
        expect(target.electricity_monthly_consumption.last).to eq([2025, 4, 1440, 1440, 1396.8, false, false, false])
      end

      it 'with insufficient data' do
        run(Date.new(2025, 5, 15), 1.year)
        expect(target.reload.electricity_monthly_consumption).to eq([[2024, 5, 816, nil, nil, true, true, false],
                                                                     [2024, 6, 1440, nil, nil, false, true, false],
                                                                     [2024, 7, 1488, nil, nil, false, true, false],
                                                                     [2024, 8, 1488, nil, nil, false, true, false],
                                                                     [2024, 9, 1440, nil, nil, false, true, false],
                                                                     [2024, 10, 1488, nil, nil, false, true, false],
                                                                     [2024, 11, 1440, nil, nil, false, true, false],
                                                                     [2024, 12, 1488, nil, nil, false, true, false],
                                                                     [2025, 1, 1488, nil, nil, false, true, false],
                                                                     [2025, 2, 1344, nil, nil, false, true, false],
                                                                     [2025, 3, 1488, nil, nil, false, true, false],
                                                                     [2025, 4, 1440, nil, nil, false, true, false]])
      end

      it 'works with an incomplete month' do
        run(Date.new(2025, 3, 15), 2.years)
        expect(target.reload.electricity_monthly_consumption.last).to \
          eq([2025, 4, nil, 1440, 1396.8, true, false, false])
      end

      it 'uses manual readings' do
        school.manual_readings.create!(month: Date.new(2023, 5), electricity: 1000)
        school.manual_readings.create!(month: Date.new(2023, 6), electricity: 1010)
        run(Date.new(2025, 3, 15), 21.months)
        expect(target.reload.electricity_monthly_consumption[0..1]).to \
          eq([[2024, 5, 1488, 1000, 970.0, false, false, true],
              [2024, 6, 1440, 1010, 979.7, false, false, true]])
      end
    end
  end
end
