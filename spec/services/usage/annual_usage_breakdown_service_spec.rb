# frozen_string_literal: true

require 'rails_helper'

describe Usage::AnnualUsageBreakdownService, type: :service do
  subject(:service) do
    described_class.new(meter_collection: meter_collection2, fuel_type: fuel_type)
  end

  let(:fuel_type) { :electricity }

  # AMR data for the school
  let(:kwh_data_x48)    { Array.new(48) { 10.0 } }
  let(:amr_start_date)  { Date.new(2021, 12, 31) }
  let(:amr_end_date)    { Date.new(2022, 12, 31) }
  let(:amr_data) { build(:amr_data, :with_date_range, :with_grid_carbon_intensity, grid_carbon_intensity: grid_carbon_intensity, start_date: amr_start_date, end_date: amr_end_date, kwh_data_x48: kwh_data_x48) }

  # Carbon intensity used to calculate co2 emissions
  let(:grid_carbon_intensity) { build(:grid_carbon_intensity, :with_days, start_date: amr_start_date, end_date: amr_end_date, kwh_data_x48: Array.new(48) { 0.2 }) }

  let(:holidays)     { build(:holidays, :with_calendar_year, year: 2022) }

  let(:school_times) do
    [{ day: :monday, usage_type: :school_day, opening_time: TimeOfDay.new(7, 0), closing_time: TimeOfDay.new(16, 0), calendar_period: :term_times }]
  end

  let(:open_close_times)      { build(:open_close_times, :from_frontend_times, school_times: school_times) }

  let(:open_close_breakdown)  { CommunityUseBreakdown.new(aggregate_meter, open_close_times) }

  let(:aggregate_meter) { build(:meter, :with_flat_rate_tariffs, type: fuel_type, amr_data: amr_data, tariff_start_date: amr_start_date, tariff_end_date: amr_end_date) }

  let(:meter_collection2) { build(:meter_collection) }

  let(:meter_collection) { @acme_academy }

  before(:all) do
    @acme_academy = load_unvalidated_meter_collection(school: 'acme-academy')
    @beta_academy = load_unvalidated_meter_collection(school: 'beta-academy')
  end

  before do
    # set during aggregation
    meter_collection2.set_aggregate_meter(fuel_type, aggregate_meter)
    # set during aggregation
    aggregate_meter.amr_data.open_close_breakdown = open_close_breakdown
    # set during aggregation
    aggregate_meter.set_tariffs
  end

  describe '#enough_data?' do
    context 'with electricity' do
      context 'with enough data' do
        it { is_expected.to be_enough_data }
      end

      context 'with limited data' do
        let(:amr_start_date) { Date.new(2022, 12, 1) }

        it 'returns false' do
          expect(service.enough_data?).to be false
        end
      end
    end

    context 'with gas' do
      let(:fuel_type) { :gas }

      context 'when there is enough data' do
        it 'returns true' do
          expect(service.enough_data?).to be true
        end
      end

      context 'with limited data' do
        let(:amr_start_date) { Date.new(2022, 12, 1) }

        it 'returns false' do
          expect(service.enough_data?).to be false
        end
      end
    end
  end

  describe '#data_available_from' do
    context 'with enough data' do
      it 'returns nil' do
        expect(service.data_available_from).to be(nil)
      end
    end

    context 'with limited data' do
      let(:amr_start_date) { Date.new(2022, 12, 1) }

      it 'returns date when there is one years data' do
        expect(service.data_available_from).to eq(amr_start_date + 364)
      end
    end
  end

  describe '#annual_out_of_hours_kwh' do
    let(:service) do
      described_class.new(meter_collection: meter_collection, fuel_type: fuel_type)
    end

    let(:usage) { service.annual_out_of_hours_kwh }

    it 'returns the expected data' do
      expect(usage[:out_of_hours]).to be_within(0.01).of(260_969.96)
      expect(usage[:total_annual]).to be_within(0.01).of(408_845.4)
    end
  end

  describe '#usage_breakdown' do
    let(:service) do
      described_class.new(meter_collection: meter_collection, fuel_type: fuel_type)
    end

    let(:day_type_breakdown) { service.usage_breakdown }

    context 'with electricity' do
      let(:fuel_type) { :electricity }

      it 'returns the holiday usage analysis' do
        expect(day_type_breakdown.holiday.kwh).to be_within(0.01).of(63_961.49)
        expect(day_type_breakdown.holiday.co2).to be_within(0.01).of(9461.34)
        expect(day_type_breakdown.holiday.percent).to be_within(0.01).of(0.15)
        expect(day_type_breakdown.holiday.£).to be_within(0.01).of(9594.22)
      end

      it 'returns the school day closed usage analysis' do
        expect(day_type_breakdown.school_day_closed.kwh).to be_within(0.01).of(159_532.06)
        expect(day_type_breakdown.school_day_closed.co2).to be_within(0.01).of(28_572.72)
        expect(day_type_breakdown.school_day_closed.percent).to be_within(0.01).of(0.39)
        expect(day_type_breakdown.school_day_closed.£).to be_within(0.01).of(23_929.80)
      end

      it 'returns the school day open usage analysis' do
        expect(day_type_breakdown.school_day_open.kwh).to be_within(0.01).of(147_875.43)
        expect(day_type_breakdown.school_day_open.co2).to be_within(0.01).of(24_419.41)
        expect(day_type_breakdown.school_day_open.percent).to be_within(0.01).of(0.36)
        expect(day_type_breakdown.school_day_open.£).to be_within(0.01).of(22_181.31)
      end

      it 'returns the out of hours usage analysis' do
        expect(day_type_breakdown.out_of_hours.kwh).to be_within(0.01).of(260_969.96)
        expect(day_type_breakdown.out_of_hours.co2).to be_within(0.01).of(43_716.01)
        expect(day_type_breakdown.out_of_hours.percent).to be_within(0.01).of(0.64)
        expect(day_type_breakdown.out_of_hours.£).to be_within(0.01).of(39_145.49)
      end

      it 'returns the weekend usage analysis' do
        expect(day_type_breakdown.weekend.kwh).to be_within(0.01).of(37_476.39)
        expect(day_type_breakdown.weekend.co2).to be_within(0.01).of(5681.93)
        expect(day_type_breakdown.weekend.percent).to be_within(0.01).of(0.09)
        expect(day_type_breakdown.weekend.£).to be_within(0.01).of(5621.45)
      end

      it 'returns the community use analysis' do
        expect(day_type_breakdown.community.kwh).to be_within(0.01).of(0) # 0
        expect(day_type_breakdown.community.co2).to be_within(0.01).of(0) # 0
        expect(day_type_breakdown.community.percent).to be_within(0.01).of(0) # 0
        expect(day_type_breakdown.community.£).to be_within(0.01).of(0) # 0
      end

      it 'returns the totals' do
        expect(day_type_breakdown.total.kwh).to be_within(0.01).of(408_845.4)
        expect(day_type_breakdown.total.co2).to be_within(0.01).of(68_135.42)
      end
    end

    context 'with storage heater' do
      let(:fuel_type) { :storage_heater }
      let(:meter_collection) { @beta_academy }

      it 'returns the holiday usage analysis' do
        expect(day_type_breakdown.holiday.kwh).to be_within(0.01).of(16_929.86)
        expect(day_type_breakdown.holiday.co2).to be_within(0.01).of(2073.21)
        expect(day_type_breakdown.holiday.percent).to be_within(0.01).of(0.15)
        expect(day_type_breakdown.holiday.£).to be_within(0.01).of(2289.13)
      end

      it 'returns the school day closed usage analysis' do
        expect(day_type_breakdown.school_day_closed.kwh).to be_within(0.01).of(79_830.78)
        expect(day_type_breakdown.school_day_closed.co2).to be_within(0.01).of(12_355.28)
        expect(day_type_breakdown.school_day_closed.percent).to be_within(0.01).of(0.71)
        expect(day_type_breakdown.school_day_closed.£).to be_within(0.01).of(9419.55)
      end

      it 'returns the school day open usage analysis' do
        expect(day_type_breakdown.school_day_open.kwh).to be_within(0.01).of(0.00)
        expect(day_type_breakdown.school_day_open.co2).to be_within(0.01).of(0.00)
        expect(day_type_breakdown.school_day_open.percent).to be_within(0.01).of(0.00)
        expect(day_type_breakdown.school_day_open.£).to be_within(0.01).of(0.00)
      end

      it 'returns the out of hours usage analysis' do
        expect(day_type_breakdown.out_of_hours.kwh).to be_within(0.01).of(111_567.32)
        expect(day_type_breakdown.out_of_hours.co2).to be_within(0.01).of(16_711.01)
        expect(day_type_breakdown.out_of_hours.percent).to be_within(0.01).of(1.0)
        expect(day_type_breakdown.out_of_hours.£).to be_within(0.01).of(13_468.68)
      end

      it 'returns the weekend usage analysis' do
        expect(day_type_breakdown.weekend.kwh).to be_within(0.01).of(14_806.67)
        expect(day_type_breakdown.weekend.co2).to be_within(0.01).of(2282.51)
        expect(day_type_breakdown.weekend.percent).to be_within(0.01).of(0.13)
        expect(day_type_breakdown.weekend.£).to be_within(0.01).of(1759.99)
      end

      it 'returns the community use analysis' do
        expect(day_type_breakdown.community.kwh).to be_within(0.005).of(0)
        expect(day_type_breakdown.community.co2).to be_within(0.005).of(0)
        expect(day_type_breakdown.community.percent).to be_within(0.005).of(0)
        expect(day_type_breakdown.community.£).to be_within(0.005).of(0)
      end

      it 'returns the totals' do
        expect(day_type_breakdown.total.kwh).to be_within(0.01).of(111_567.32)
        expect(day_type_breakdown.total.co2).to be_within(0.01).of(16_711.01)
      end
    end
  end
end
