# frozen_string_literal: true

require 'rails_helper'

describe Usage::CalculationService, :aggregate_failures, type: :service do
  let(:asof_date) { Date.new(2022, 2, 1) }
  let(:meter_collection) { load_unvalidated_meter_collection(school: 'acme-academy') }
  let(:meter) { meter_collection.aggregated_electricity_meters }
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
      let(:meter)          { meter_collection.aggregated_heat_meters }

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
        expect(usage.kwh).to be_within(0.01).of(449_547.99)
        expect(usage.gbp).to be_within(0.01).of(53_697.67)
        expect(usage.co2).to be_within(0.01).of(86_754.08)
      end

      it 'calculates the expected values for last year' do
        usage = service.usage(period: :last_year)
        expect(usage.kwh).to be_within(0.01).of(402_384.69)
        expect(usage.gbp).to be_within(0.01).of(50_458.50)
        expect(usage.co2).to be_within(0.01).of(77_977.43)
      end

      it 'calculates the expected values for last month' do
        usage = service.usage(period: :last_month)
        expect(usage.kwh).to be_within(0.01).of(51_337.60)
        expect(usage.gbp).to be_within(0.01).of(6268.46)
        expect(usage.co2).to be_within(0.01).of(10_614.10)
      end

      it 'calculates the expected values for last month in the previous year' do
        usage = service.usage(period: :last_month_previous_year)
        expect(usage.kwh).to be_within(0.01).of(30_767.30)
        expect(usage.gbp).to be_within(0.01).of(3699.71)
        expect(usage.co2).to be_within(0.01).of(7001.50)
      end
    end

    context 'with gas' do
      let(:meter) { meter_collection.aggregated_heat_meters }

      it 'calculates the expected values for this year' do
        usage = service.usage
        expect(usage.kwh).to be_within(0.01).of(632_332.89)
        expect(usage.gbp).to be_within(0.01).of(18_969.99)
        expect(usage.co2).to be_within(0.01).of(115_419.72)
      end

      it 'calculates the expected values for last year' do
        usage = service.usage(period: :last_year)
        expect(usage.kwh).to be_within(0.01).of(650_831.23)
        expect(usage.gbp).to be_within(0.01).of(19_524.93)
        expect(usage.co2).to be_within(0.01).of(118_796.23)
      end
    end
  end

  describe '#annual_usage_change_since_last_year' do
    context 'with electricity' do
      it 'calculates the expected values' do
        usage_change = service.annual_usage_change_since_last_year
        # values checked against electricity long term trend alert
        expect(usage_change.kwh).to be_within(0.01).of(47_163.29)
        expect(usage_change.gbp).to be_within(0.01).of(3239.16)
        expect(usage_change.co2).to be_within(0.01).of(8776.65)
        expect(usage_change.percent).to be_within(0.01).of(0.11)
      end

      context 'when there isnt enough data' do
        let(:asof_date) { Date.new(2021, 1, 1) }

        it 'returns nil' do
          expect(service.annual_usage_change_since_last_year).to be_nil
        end
      end
    end

    context 'with gas' do
      let(:meter) { meter_collection.aggregated_heat_meters }

      it 'calculates the expected values' do
        usage_change = service.annual_usage_change_since_last_year
        # values checked against gas long term trend alert
        expect(usage_change.kwh).to be_within(0.01).of(-18_498.348)
        expect(usage_change.gbp).to be_within(0.01).of(-554.95)
        expect(usage_change.co2).to be_within(0.01).of(-3376.50)
        expect(usage_change.percent).to be_within(0.01).of(-0.02)
      end

      context 'when there isnt enough data' do
        let(:asof_date) { Date.new(2019, 1, 1) }

        it 'returns nil' do
          expect(service.annual_usage_change_since_last_year).to be_nil
        end
      end
    end
  end
end
