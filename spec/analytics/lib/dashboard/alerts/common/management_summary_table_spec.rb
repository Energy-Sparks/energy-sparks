# frozen_string_literal: true

require 'rails_helper'
require 'dashboard'

describe ManagementSummaryTable do
  subject(:alert) do
    described_class.new(meter_collection)
  end

  let(:start_date) { Date.new(2022, 11, 11) }
  let(:today) { Date.new(2023, 11, 30) }

  before { travel_to(today) }

  describe '#reporting_period' do
    let(:meter_collection) do
      build(:meter_collection, :with_fuel_and_aggregate_meters,
            start_date: start_date, end_date: today)
    end

    it 'returns expected period' do
      expect(alert.reporting_period).to eq(:last_12_months)
    end
  end

  # Notes on kwh, co2, £ calculations
  # By default the meter collection factory creates meter with data that has
  # 48 kWh per day
  # 0.1p per kWh tariffs
  # co2 of rand(0.2..0.3).round(3)
  describe '#analyse' do
    let(:variables) do
      alert.variables_for_reporting
    end

    context 'when school has only electricity' do
      subject(:electricity_data) { variables.dig(:summary_data, :electricity) }

      let(:meter_collection) do
        build(:meter_collection, :with_fuel_and_aggregate_meters,
              start_date: start_date, end_date: today)
      end

      before { alert.analyse(today) }

      it { expect(alert.calculation_worked).to be true }
      it { expect(electricity_data[:start_date]).to eq(start_date.iso8601) }
      it { expect(electricity_data[:end_date]).to eq(today.iso8601) }

      it 'marks all data as recent' do
        %i[last_month workweek year].each do |period|
          expect(electricity_data.dig(period, :recent)).to be true
        end
      end

      it 'does not generate gas variables' do
        expect(variables.dig(:summary_data, :gas)).to be_nil
      end

      it 'does not generate storage_heater variables' do
        expect(variables.dig(:summary_data, :storage_heaters)).to be_nil
      end

      it 'calculates co2 values' do
        %i[last_month workweek year].each do |period|
          expect(electricity_data.dig(period, :co2)).to be > 0
        end
      end

      it 'calculates work week' do
        expect(electricity_data.dig(:workweek, :kwh)).to eq(7 * 48.0)
        expect(electricity_data.dig(:workweek, :£)).to be_within(0.0001).of(7 * 48.0 * 0.1)
        expect(electricity_data.dig(:workweek, :percent_change)).to eq(0.0)
      end

      it 'calculates last_month' do
        # For end of 2022-11-30, last month will be October, so 31 days
        expect(electricity_data.dig(:last_month, :kwh)).to eq(31.0 * 48)
        expect(electricity_data.dig(:last_month, :£)).to be_within(0.0001).of(31.0 * 48 * 0.1)
        expect(electricity_data.dig(:last_month, :percent_change)).to eq('n/a')
      end

      it 'calculates last year' do
        expect(electricity_data.dig(:year, :kwh)).to eq(364 * 48.0)
        expect(electricity_data.dig(:year, :£)).to be_within(0.0001).of(364 * 48.0 * 0.1)
        expect(electricity_data.dig(:year, :percent_change)).to eq('n/a')
      end

      context 'with several years of data' do
        let(:start_date) { Date.new(2020, 11, 1) }

        it 'calculates last_month' do
          # For end of 2022-11-30, last month will be October, so 31 days
          expect(electricity_data.dig(:last_month, :kwh)).to eq(31 * 48.0)
          expect(electricity_data.dig(:last_month, :£)).to be_within(0.0001).of(31 * 48.0 * 0.1)
          expect(electricity_data.dig(:last_month, :percent_change)).to eq(0.0)
        end

        it 'calculates last year' do
          expect(electricity_data.dig(:year, :kwh)).to eq(364 * 48.0)
          expect(electricity_data.dig(:year, :£)).to be_within(0.0001).of(364 * 48.0 * 0.1)
          expect(electricity_data.dig(:year, :percent_change)).to eq(0.0)
        end
      end

      context 'when the data is stale' do
        let(:meter_collection) do
          build(:meter_collection, :with_fuel_and_aggregate_meters,
                start_date: start_date, end_date: Date.new(2023, 6, 1))
        end

        it 'indicates when annual data is available' do
          expect(electricity_data[:year][:available_from]).to eq((start_date + 1.year).iso8601)
        end

        it 'indicates that other data is not recent' do
          %i[workweek last_month].each do |period|
            expect(electricity_data.dig(period, :recent)).to be false
          end
        end
      end

      context 'when there is less than a year of data' do
        let(:start_date) { today - 60.days }

        it 'indicates when annual data is available' do
          expect(electricity_data[:year][:available_from]).to eq((start_date + 365.days).iso8601)
        end

        it 'calculates work week' do
          expect(electricity_data.dig(:workweek, :kwh)).to eq(7 * 48.0)
          expect(electricity_data.dig(:workweek, :£)).to be_within(0.0001).of(7 * 48.0 * 0.1)
          expect(electricity_data.dig(:workweek, :percent_change)).to eq(0.0)
        end

        it 'calculates last_month' do
          # For end of 2022-11-30, last month will be October, so 31 days
          expect(electricity_data.dig(:last_month, :kwh)).to eq(31.0 * 48)
          expect(electricity_data.dig(:last_month, :£)).to be_within(0.0001).of(31.0 * 48 * 0.1)
          expect(electricity_data.dig(:last_month, :percent_change)).to eq('n/a')
        end
      end

      context 'when there is less than a month of data' do
        # today is 2023-11-30
        # this is 2023-11-09
        let(:start_date) { today - 21.days }

        it 'indicates when annual data is available' do
          expect(electricity_data[:year][:available_from]).to eq((start_date + 365.days).iso8601)
        end

        it 'indicates when monthly data is available' do
          # start date will be 2023-11-09 we can report on previous month from around 1st December
          expect(electricity_data[:last_month][:available_from]).to eq(Date.new(2023, 12, 1).iso8601)
        end

        it 'calculates work week' do
          expect(electricity_data.dig(:workweek, :kwh)).to eq(7 * 48.0)
          expect(electricity_data.dig(:workweek, :£)).to be_within(0.0001).of(7 * 48.0 * 0.1)
          expect(electricity_data.dig(:workweek, :percent_change)).to eq(0.0)
        end
      end

      context 'when there is less than two full months of data' do
        # this is 2023-10-16
        # available from should be 2023-12-1 as we would then have all of November.
        let(:start_date) { today - 45.days }

        it 'indicates when annual data is available' do
          expect(electricity_data[:year][:available_from]).to eq((start_date + 365.days).iso8601)
        end

        it 'indicates when monthly data is available' do
          # start date will be 2023-11-09 we can report on previous month from around 1st December
          expect(electricity_data[:last_month][:available_from]).to eq(Date.new(2023, 12, 1).iso8601)
        end

        it 'calculates work week' do
          expect(electricity_data.dig(:workweek, :kwh)).to eq(7 * 48.0)
          expect(electricity_data.dig(:workweek, :£)).to be_within(0.0001).of(7 * 48.0 * 0.1)
          expect(electricity_data.dig(:workweek, :percent_change)).to eq(0.0)
        end
      end
    end

    context 'when school has electricity and solar' do
      subject(:electricity_data) { variables.dig(:summary_data, :electricity) }

      let(:meter_collection) do
        meter_collection = build(:meter_collection, start_date: start_date, end_date: today)
        electricity_meter = build(:meter,
                                  :with_flat_rate_tariffs,
                                  tariff_start_date: start_date,
                                  tariff_end_date: today,
                                  meter_collection: meter_collection,
                                  type: :electricity,
                                  meter_attributes: {
                                    solar_pv: [{ start_date: start_date, kwp: 10.0 }]
                                  },
                                  amr_data: build(:amr_data, :with_date_range,
                                                  type: :electricity,
                                                  start_date: start_date,
                                                  end_date: today,
                                                  kwh_data_x48: Array.new(48, 1.0)))
        meter_collection.add_electricity_meter(electricity_meter)
        meter_collection
      end

      before do
        AggregateDataService.new(meter_collection).aggregate_heat_and_electricity_meters
        alert.analyse(today)
      end

      it { expect(alert.calculation_worked).to be true }
      it { expect(electricity_data[:start_date]).to eq(start_date.iso8601) }
      it { expect(electricity_data[:end_date]).to eq(today.iso8601) }

      it 'calculates offset co2' do
        electricity_data = variables.dig(:summary_data, :electricity)
        consumption = meter_collection.electricity_meters.first.amr_data.kwh_date_range(today - 363, today, :co2)
        pv_production = meter_collection.aggregate_meter(:solar_pv).amr_data.kwh_date_range(today - 363, today, :co2)
        expect(electricity_data.dig(:year, :co2)).to eq(consumption + pv_production)
      end
    end

    context 'when school has gas' do
      subject(:gas_data) { variables.dig(:summary_data, :gas) }

      let(:meter_collection) do
        build(:meter_collection, :with_fuel_and_aggregate_meters,
              start_date: start_date, end_date: today, fuel_type: :gas)
      end

      before do
        AggregateDataService.new(meter_collection).aggregate_heat_and_electricity_meters
        alert.analyse(today)
      end

      it { expect(alert.calculation_worked).to be true }
      it { expect(gas_data[:start_date]).to eq(start_date.iso8601) }
      it { expect(gas_data[:end_date]).to eq(today.iso8601) }

      it 'does not generate electricity variables' do
        expect(variables.dig(:summary_data, :electricity)).to be_nil
      end

      it 'does not generate storage_heater variables' do
        expect(variables.dig(:summary_data, :storage_heaters)).to be_nil
      end

      it 'calculates gas variables' do
        expect(gas_data).not_to be_nil
      end

      context 'with no recorded usage' do
        let(:meter_collection) do
          meter_collection = build(:meter_collection, start_date: start_date, end_date: today)
          electricity_meter = build(:meter,
                                    :with_flat_rate_tariffs,
                                    tariff_start_date: start_date,
                                    tariff_end_date: today,
                                    meter_collection: meter_collection,
                                    type: :gas,
                                    amr_data: build(:amr_data, :with_date_range,
                                                    type: :electricity,
                                                    start_date: start_date,
                                                    end_date: today,
                                                    kwh_data_x48: Array.new(48, 0.0)))
          meter_collection.add_heat_meter(electricity_meter)
          meter_collection
        end

        it { expect(alert.calculation_worked).to be true }
        it { expect(gas_data[:start_date]).to eq(start_date.iso8601) }
        it { expect(gas_data[:end_date]).to eq(today.iso8601) }

        it 'marks all data as recent' do
          %i[last_month workweek year].each do |period|
            expect(gas_data.dig(period, :recent)).to be true
          end
        end

        it 'produces zeroes for all usage metrics' do
          %i[last_month workweek year].each do |period|
            %i[kwh £ co2].each do |metric|
              expect(gas_data.dig(period, metric)).to eq(0.0)
            end
          end
        end

        it 'calculates percentage changes' do
          expect(gas_data[:workweek][:percent_change]).to eq(0.0)
          expect(gas_data[:last_month][:percent_change]).to eq('n/a')
          expect(gas_data[:year][:percent_change]).to eq('n/a')
        end
      end
    end

    context 'when school has storage heaters' do
      let(:meter_collection) do
        build(:meter_collection, :with_fuel_and_aggregate_meters,
              start_date: start_date, end_date: today, storage_heaters: true)
      end

      before { alert.analyse(today) }

      it { expect(alert.calculation_worked).to be true }

      it 'generates electricity variables' do
        expect(variables.dig(:summary_data, :electricity)).not_to be_nil
      end

      it 'generates storage_heater variables' do
        expect(variables.dig(:summary_data, :storage_heaters)).not_to be_nil
      end

      it 'does not generate gas variables' do
        expect(variables.dig(:summary_data, :gas)).to be_nil
      end
    end
  end
end
