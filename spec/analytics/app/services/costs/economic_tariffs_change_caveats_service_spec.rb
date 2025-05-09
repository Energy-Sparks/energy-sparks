# frozen_string_literal: true

require 'rails_helper'
describe Costs::EconomicTariffsChangeCaveatsService do
  include_context 'with an aggregated meter with tariffs and school times' do
    let(:amr_start_date)  { start_date }
    let(:amr_end_date)    { end_date }
  end

  subject(:service) do
    described_class.new(meter_collection: meter_collection, fuel_type: :electricity)
  end

  let(:start_date)  { Date.new(2023, 1, 2) }
  let(:end_date)    { Date.new(2023, 12, 31) }

  describe '#calculate_economic_tariff_changed' do
    subject(:caveats) do
      service.calculate_economic_tariff_changed
    end

    context 'when tariffs havent changed' do
      it { expect(caveats).to be(nil) }
    end

    context 'when tariffs have changed' do
      let(:newest_tariff_start) { end_date - 1 }
      let(:newest_tariff_end)   { nil }

      include_context 'with an aggregated meter with tariffs and school times' do
        let(:amr_start_date)  { start_date }
        let(:amr_end_date)    { end_date }

        let(:aggregate_meter) do
          tariffs = [
            create_accounting_tariff_generic(
              start_date: start_date,
              end_date: start_date + 6,
              rates: create_flat_rate(rate: 0.5)
            ),
            create_accounting_tariff_generic(
              start_date: start_date + 7,
              end_date: newest_tariff_start - 1,
              rates: create_flat_rate(rate: 1.0)
            ),
            create_accounting_tariff_generic(
              start_date: newest_tariff_start,
              end_date: newest_tariff_end,
              rates: create_flat_rate(rate: 2.0)
            )
          ]
          build(:meter, :with_tariffs,
                type: fuel_type, amr_data: amr_data,
                accounting_tariffs: tariffs)
        end
      end

      it 'calculates economic tariff changed data' do
        expect(caveats.last_change_date).to eq(newest_tariff_start)
        expect(caveats.rate_after_£_per_kwh).to be_within(0.1).of(2.0)
        expect(caveats.rate_before_£_per_kwh).to be_within(0.1).of(1.0)
        expect(caveats.percent_change).to be_within(0.1).of(1.0)
      end
    end
  end
end
