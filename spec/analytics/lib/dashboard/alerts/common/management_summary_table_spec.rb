# frozen_string_literal: true

require 'rails_helper'
require 'dashboard'

describe ManagementSummaryTable do
  subject(:alert) do
    described_class.new(meter_collection)
  end

  let(:start_date) { Date.new(2022, 11, 1) }
  let(:today) { Date.new(2023, 11, 30) }

  describe '#reporting_period' do
    let(:meter_collection) do
      build(:meter_collection, :with_fuel_and_aggregate_meters,
            start_date: start_date, end_date: today)
    end

    it 'returns expected period' do
      expect(alert.reporting_period).to eq(:last_12_months)
    end
  end

  describe '#analyse' do
    let(:result) do
      alert.analyse(today)
    end
    let(:variables) do
      alert.variables_for_reporting
    end

    context 'when school has only electricity' do
      let(:meter_collection) do
        build(:meter_collection, :with_fuel_and_aggregate_meters,
              start_date: start_date, end_date: today)
      end

      it 'runs the calculation and produces expected variables' do
        expect(result).to be true
        expect(variables.dig(:summary_data, :electricity)).not_to be_nil
        electricity_data = variables.dig(:summary_data, :electricity)
        expect(electricity_data[:start_date]).to eq(start_date.iso8601)
        expect(electricity_data[:end_date]).to eq(today.iso8601)

        expect(electricity_data.dig(:year, :recent)).to be true
        expect(electricity_data.dig(:workweek, :recent)).to be true

        # Notes on kwh, co2, £ calculations
        # By default the meter collection factory creates meter with data that has
        # 48 kWh per day, tariffs of 0.1 per kWh, co2 of rand(0.2..0.3).round(3)
        expect(electricity_data.dig(:workweek, :kwh)).to eq(336.0)
        expect(electricity_data.dig(:workweek, :£)).to be_within(0.0001).of(33.6)
        expect(electricity_data.dig(:workweek, :co2)).to be > 0

        expect(electricity_data.dig(:year, :kwh)).to eq(17_472.0)
        expect(electricity_data.dig(:year, :£)).to be_within(0.0001).of(1747.20)
        expect(electricity_data.dig(:year, :co2)).to be > 0

        expect(variables.dig(:summary_data, :gas)).to be_nil
        expect(variables.dig(:summary_data, :storage_heaters)).to be_nil
      end
    end

    context 'when school has electricity and solar' do
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
      end

      it 'calculates offset co2' do
        expect(result).to be true
        electricity_data = variables.dig(:summary_data, :electricity)
        consumption = meter_collection.electricity_meters.first.amr_data.kwh_date_range(today - 363, today, :co2)
        pv_production = meter_collection.aggregate_meter(:solar_pv).amr_data.kwh_date_range(today - 363, today, :co2)
        expect(electricity_data.dig(:year, :co2)).to eq(consumption + pv_production)
      end
    end

    context 'when school has gas' do
      let(:meter_collection) do
        build(:meter_collection, :with_fuel_and_aggregate_meters,
              start_date: start_date, end_date: today, fuel_type: :gas)
      end

      it 'runs the calculation and produces expected variables' do
        expect(result).to be true
        expect(variables.dig(:summary_data, :gas)).not_to be_nil
        expect(variables.dig(:summary_data, :electricity)).to be_nil
        expect(variables.dig(:summary_data, :storage_heaters)).to be_nil
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

        before do
          AggregateDataService.new(meter_collection).aggregate_heat_and_electricity_meters
        end

        it 'runs the calculation and produces expected variables' do
          expect(result).to be true
          expect(variables.dig(:summary_data, :gas)).not_to be_nil
          gas_data = variables.dig(:summary_data, :gas)
          expect(gas_data[:start_date]).to eq(start_date.iso8601)
          expect(gas_data[:end_date]).to eq(today.iso8601)

          expect(gas_data.dig(:year, :recent)).to be true
          expect(gas_data.dig(:workweek, :recent)).to be true

          %i[workweek year].each do |period|
            %i[kwh £ co2].each do |metric|
              expect(gas_data.dig(period, metric)).to eq(0.0)
            end

            %i[savings_£ percent_change].each do |metric|
              expect(gas_data.dig(period, metric)).to eq('n/a')
            end
          end
        end
      end
    end

    context 'when school has storage heaters' do
      let(:meter_collection) do
        build(:meter_collection, :with_fuel_and_aggregate_meters,
              start_date: start_date, end_date: today, storage_heaters: true)
      end

      it 'runs the calculation and produces expected variables' do
        expect(result).to be true
        expect(variables.dig(:summary_data, :gas)).to be_nil
        expect(variables.dig(:summary_data, :electricity)).not_to be_nil
        expect(variables.dig(:summary_data, :storage_heaters)).not_to be_nil
      end
    end
  end
end
