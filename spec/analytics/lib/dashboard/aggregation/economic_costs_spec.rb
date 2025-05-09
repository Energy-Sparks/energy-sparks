# frozen_string_literal: true

require 'rails_helper'

describe EconomicCosts do
  let(:start_date)  { Date.new(2023, 1, 1) }
  let(:end_date)    { Date.new(2023, 1, 31) }

  let(:rates)       { create_flat_rate(rate: 0.15, standing_charge: 1.0) }

  let(:kwh_data_x48) { Array.new(48, 0.01) }

  let(:combined_meter) { build(:meter) }
  let(:meter1) do
    build(:meter,
          :with_flat_rate_tariffs,
          rates: rates,
          tariff_start_date: start_date,
          tariff_end_date: end_date,
          type: :electricity,
          amr_data: build(:amr_data, :with_days, day_count: 31, end_date: end_date,
                                                 kwh_data_x48: kwh_data_x48))
  end

  let(:meter2) do
    build(:meter,
          :with_flat_rate_tariffs,
          rates: rates,
          tariff_start_date: start_date,
          tariff_end_date: end_date,
          type: :electricity,
          amr_data: build(:amr_data, :with_days, day_count: 31, end_date: end_date,
                                                 kwh_data_x48: kwh_data_x48))
  end

  let(:list_of_meters)      { [meter1, meter2] }

  let(:combined_start_date) { start_date }
  let(:combined_end_date)   { end_date }

  describe '#combine_economic_costs_from_multiple_meters' do
    let(:combined_costs) do
      described_class.combine_economic_costs_from_multiple_meters(combined_meter, list_of_meters, combined_start_date,
                                                                  combined_end_date)
    end

    # usage * rate * 48 hh periods * 2 meters
    let(:expected_total_cost) { (0.01 * 0.15) * 48 * 2 }

    it 'has expected type' do
      expect(combined_costs).to be_a EconomicCostsPrecalculated
    end

    it 'has expected numbers of days' do
      expect(combined_costs.date_range).to eq(start_date..end_date)
    end

    it 'has expected bill_component_types' do
      # no standing charge as this is economic costs
      expect(combined_costs.bill_component_types).to match_array(['flat_rate'])
    end

    it 'has expected cost for start date' do
      expect(combined_costs.one_day_total_cost(start_date).round(3)).to eq expected_total_cost.round(3)
    end

    it 'has expected cost for end date' do
      expect(combined_costs.one_day_total_cost(end_date).round(3)).to eq expected_total_cost.round(3)
    end
  end

  describe '#combine_current_economic_costs_from_multiple_meters' do
    let(:accounting_tariff) do
      create_accounting_tariff_generic(start_date: start_date, end_date: end_date - 1, rates: rates)
    end

    let(:current_rates) { create_flat_rate(rate: 1.5) }

    let(:current_accounting_tariff) do
      create_accounting_tariff_generic(start_date: end_date, end_date: end_date, rates: current_rates)
    end

    #    let(:meter_attributes) do
    #      { accounting_tariff_generic: [accounting_tariff, current_accounting_tariff] }
    #    end

    let(:meter1) do
      build(:meter,
            :with_tariffs,
            accounting_tariffs: [accounting_tariff, current_accounting_tariff],
            type: :electricity,
            amr_data: build(:amr_data, :with_days, day_count: 31, end_date: end_date,
                                                   kwh_data_x48: kwh_data_x48))
    end

    let(:meter2) do
      build(:meter,
            :with_tariffs,
            accounting_tariffs: [accounting_tariff, current_accounting_tariff],
            type: :electricity,
            amr_data: build(:amr_data, :with_days, day_count: 31, end_date: end_date,
                                                   kwh_data_x48: kwh_data_x48))
    end

    let(:combined_costs) do
      described_class.combine_current_economic_costs_from_multiple_meters(combined_meter, list_of_meters,
                                                                          combined_start_date, combined_end_date)
    end

    # usage * rate * 48 hh periods * 2 meters
    let(:expected_total_cost) { (0.01 * 1.5) * 48 * 2 }

    it 'has expected type' do
      expect(combined_costs).to be_a CurrentEconomicCostsPrecalculated
    end

    it 'has expected numbers of days' do
      expect(combined_costs.date_range).to eq(start_date..end_date)
    end

    it 'has expected bill_component_types' do
      # no standing charge as this is economic costs
      expect(combined_costs.bill_component_types).to match_array(['flat_rate'])
    end

    # should be using cost for latest tariff, not earliest
    it 'has expected cost for start date' do
      expect(combined_costs.one_day_total_cost(start_date).round(3)).to eq expected_total_cost.round(3)
    end

    it 'has expected cost for end date' do
      expect(combined_costs.one_day_total_cost(end_date).round(3)).to eq expected_total_cost.round(3)
    end
  end
end
