# frozen_string_literal: true

require 'rails_helper'

describe Usage::CalculationService, :aggregate_failures, type: :service do
  let(:start_date) { Date.new(2023, 7, 1) }
  let(:asof_date) { Date.new(2026, 7, 1) }

  let(:type) { :electricity }
  let(:meter_collection) do
    amr_data = build(:amr_data, :with_date_range, start_date: start_date, end_date: asof_date, kwh_data_x48: [50] * 48)
    amr_data.set_carbon_emissions(
      1, nil, build(:grid_carbon_intensity, :with_days, start_date: start_date, end_date: asof_date,
                                                        kwh_data_x48: [0.2] * 48)
    )
    amr_data.scale_kwh(2.0, date1: Date.new(2023, 1, 1), date2: Date.new(2025, 7, 2)) # double previous year
    collection = build(:meter_collection, start_date: start_date, end_date: asof_date)
    meter = build(:meter, :with_flat_rate_tariffs,
                  meter_collection: collection, type:, amr_data: amr_data)
    collection.set_aggregate_meter(type, meter)
    collection
  end

  let(:meter) { meter_collection.aggregate_meter(type) }
  let(:service) { described_class.new(meter, asof_date) }

  describe '#enough_data?' do
    context 'with electricity' do
      context 'with enough data' do
        it 'returns true' do
          expect(service.enough_data?).to be true
        end
      end
    end

    context 'with gas' do
      let(:type) { :gas }

      context 'with enough data' do
        it 'returns true' do
          expect(service.enough_data?).to be true
        end
      end
    end
  end

  describe '#usage' do
    context 'with electricity' do
      it 'calculates the expected values for this year' do
        usage = service.usage
        expect(usage.kwh).to be_within(0.01).of(873_600.0) # 50 * 48 * 364 days
        expect(usage.gbp).to be_within(0.01).of(87_360.0) # tariff is 0.1 * above
        expect(usage.co2).to be_within(0.01).of(174_720.0) # kwh * 0.2
      end

      it 'calculates the expected values for last year' do
        usage = service.usage(period: :last_year)
        expect(usage.kwh).to be_within(0.01).of(1_747_200.0) # 2 * 50 * 48 * 364 days
        expect(usage.gbp).to be_within(0.01).of(174_720.0) # tariff is 0.1 * above
        expect(usage.co2).to be_within(0.01).of(349_440.0) # kwh * 0.2
      end

      it 'calculates the expected values for last month' do
        usage = service.usage(period: :last_month)
        expect(usage.kwh).to be_within(0.01).of(72_000.0) # 30 days in june
        expect(usage.gbp).to be_within(0.01).of(7200.0)
        expect(usage.co2).to be_within(0.01).of(14_400)
      end

      it 'calculates the expected values for last month in the previous year' do
        usage = service.usage(period: :last_month_previous_year)
        expect(usage.kwh).to be_within(0.01).of(144_000.0) # 30 days in june
        expect(usage.gbp).to be_within(0.01).of(14_400.0)
        expect(usage.co2).to be_within(0.01).of(28_800.0)
      end
    end

    context 'with gas' do
      let(:type) { :gas }

      it 'calculates the expected values for this year' do
        usage = service.usage
        expect(usage.kwh).to be_within(0.01).of(873_600.0) # 50 * 48 * 364 days
        expect(usage.gbp).to be_within(0.01).of(87_360.0) # tariff is 0.1 * above
        expect(usage.co2).to be_within(0.01).of(174_720.0) # kwh * 0.2
      end

      it 'calculates the expected values for last month' do
        usage = service.usage(period: :last_month)
        expect(usage.kwh).to be_within(0.01).of(72_000.0) # 30 days in june
        expect(usage.gbp).to be_within(0.01).of(7200.0)
        expect(usage.co2).to be_within(0.01).of(14_400)
      end
    end
  end

  describe '#annual_usage_change_since_last_year' do
    context 'with electricity' do
      it 'calculates the expected values' do
        usage_change = service.annual_usage_change_since_last_year
        expect(usage_change.kwh).to be_within(0.01).of(-873_600.0)
        expect(usage_change.gbp).to be_within(0.01).of(-87_360.0)
        expect(usage_change.co2).to be_within(0.01).of(-174_720.0)
        expect(usage_change.percent).to be_within(0.01).of(-0.5)
      end

      context 'when there isnt enough data' do
        let(:asof_date) { Date.new(2025, 1, 1) }

        it 'returns nil' do
          expect(service.annual_usage_change_since_last_year).to be_nil
        end
      end
    end

    context 'with gas' do
      let(:type) { :gas }

      it 'calculates the expected values' do
        usage_change = service.annual_usage_change_since_last_year
        expect(usage_change.kwh).to be_within(0.01).of(-873_600.0)
        expect(usage_change.gbp).to be_within(0.01).of(-87_360.0)
        expect(usage_change.co2).to be_within(0.01).of(-174_720.0)
        expect(usage_change.percent).to be_within(0.01).of(-0.5)
      end

      context 'when there isnt enough data' do
        let(:asof_date) { Date.new(2025, 1, 1) }

        it 'returns nil' do
          expect(service.annual_usage_change_since_last_year).to be_nil
        end
      end
    end
  end
end
