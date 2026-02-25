# frozen_string_literal: true

require 'rails_helper'

describe Schools::ManualReadingsService do
  subject(:service) { described_class.new(school) }

  let(:school) { create(:school) }

  describe '#show_on_menu?' do
    context 'with no fuel configuration' do
      it { is_expected.to be_show_on_menu }
    end

    context 'with fuel configuration with too recent start date' do
      let(:school) { create(:school, :with_meter_dates) }

      it { is_expected.to be_show_on_menu }
    end

    context 'with fuel configuration with too old end date' do
      let(:school) { create(:school, :with_meter_dates, reading_end_date: 1.month.ago) }

      it { is_expected.to be_show_on_menu }
    end

    context 'with fuel configuration with enough months' do
      let(:school) { create(:school, :with_meter_dates, reading_start_date: 24.months.ago) }

      it { is_expected.not_to be_show_on_menu }
    end

    context 'with a complete target' do
      let(:school) { create(:school_target, :with_monthly_consumption).school }

      it { is_expected.to be_show_on_menu }
    end

    context 'with a previous months incomplete target' do
      let(:school) { create(:school_target, :with_monthly_consumption, previous_missing: true).school }

      it { is_expected.to be_show_on_menu }
    end

    context 'with a current months incomplete target' do
      let(:school) { create(:school_target, :with_monthly_consumption, current_missing: true).school }

      it { is_expected.to be_show_on_menu }
    end

    context 'with a current months incomplete target started two month ago' do
      let(:school) do
        create(:school_target, :with_monthly_consumption, current_missing: true, start_date: 2.months.ago).school
      end

      it { is_expected.to be_show_on_menu }
    end

    context 'with existing manual readings' do
      let(:school) { create(:manual_reading, gas: 1).school }

      it { is_expected.to be_show_on_menu }
    end

    context 'with enough electricity but not gas' do
      before do
        school.configuration.update!(aggregate_meter_dates: { electricity: { start_date: 13.months.ago.to_date.iso8601,
                                                                             end_date: Date.current.iso8601 },
                                                              gas: { start_date: 1.month.ago.to_date.iso8601,
                                                                     end_date: Date.current.iso8601 } })
      end

      it { is_expected.to be_show_on_menu }
    end
  end

  describe '#calculate_required' do
    before { travel_to(Date.new(2025, 5)) }

    def expected_readings(usage)
      usage += [1020] * 12 if usage.length < 13
      months = (1..usage.length).map { |i| Date.new(2025, 5) - i.months }.reverse
      months.zip(usage).to_h { |month, value| [month, { electricity: value }] }
    end

    context 'with a target' do
      before do
        create(:school_target, :with_monthly_consumption, school:)
        meter_collection = build(:meter_collection)
        service.calculate_required(meter_collection)
      end

      it 'calculates the correct readings' do
        expect(service.readings).to eq(expected_readings([nil] * 11))
      end
    end

    context 'with a target and meter readings' do
      before do
        create(:school_target, :with_monthly_consumption, school:)
        meter_collection = build(:meter_collection, :with_aggregate_meter, start_date: 2.years.ago.to_date,
                                                                           kwh_data_x48: [1] * 48)
        service.calculate_required(meter_collection)
      end

      it 'calculates the correct readings' do
        expect(service.readings).to \
          eq(expected_readings([1488, 1440, 1488, 1488, 1440, 1488, 1440, 1488, 1488, 1392, 1488, 1440]))
      end
    end

    context 'with meter readings' do
      before do
        meter_collection = build(:meter_collection, :with_aggregate_meter, start_date: 1.year.ago.to_date,
                                                                           kwh_data_x48: [1] * 48)
        service.calculate_required(meter_collection)
      end

      it 'calculates the correct readings' do
        expect(service.readings).to \
          eq(expected_readings([*[nil] * 12, 1488, 1440, 1488, 1488, 1440, 1488, 1440, 1488, 1488, 1344, 1488, 1440]))
      end
    end

    context 'with dual fuel meter readings with different end dates' do
      let(:school) { create(:school, :with_fuel_configuration) }

      before do
        meter_collection = build(:meter_collection)
        build(:meter, :aggregate_meter, meter_collection:, start_date: 25.months.ago.to_date, kwh_data_x48: [1] * 48,
                                                           end_date: 2.months.ago.to_date)
        build(:meter, :aggregate_meter, meter_collection:, type: :electricity, start_date: 1.year.ago.to_date,
                                                           kwh_data_x48: [2] * 48)
        service.calculate_required(meter_collection)
      end

      it 'disables months with no required reading' do
        expect(service.disabled?(Date.new(2023, 4), :electricity)).to be true
      end
    end
  end
end
