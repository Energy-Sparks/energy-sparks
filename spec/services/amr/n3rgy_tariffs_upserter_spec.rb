require 'rails_helper'

module Amr
  describe N3rgyTariffsUpserter do

    let(:meter)                       { create(:electricity_meter) }
    let(:end_date)                    { Date.today }
    let(:start_date)                  { end_date - 1 }

    let(:import_log)                  { create(:tariff_import_log) }

    let(:expected_tiered_tariff)      { {:tariffs=>{1=>0.48527000000000003, 2=>0.16774}, :thresholds=>{1=>1000}, :type=>:tiered} }
    let(:expected_prices)             { [expected_tiered_tariff, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992] }
    let(:expected_standing_charge)    { 0.19541 }

    let(:kwh_tariffs)                 { { start_date => expected_prices } }
    let(:standing_charges)            { { start_date => expected_standing_charge } }

    let(:tariffs)                     { { kwh_tariffs: kwh_tariffs, standing_charges: standing_charges } }

    let(:upserter) { Amr::N3rgyTariffsUpserter.new(meter: meter, tariffs: tariffs, import_log: import_log) }

    context 'with empty prices' do
      let(:kwh_tariffs) { { } }

      it "skips upsert" do
        upserter.perform
        expect(meter.reload.tariff_prices.count).to eq(0)
      end
    end

    context 'with empty standing charges' do
      let(:standing_charges) { { } }

      it "skips upsert" do
        upserter.perform
        expect(meter.reload.tariff_standing_charges.count).to eq(0)
      end
    end

    it "inserts new standing charges" do
      upserter.perform
      meter.reload
      expect(meter.tariff_standing_charges.count).to eq(1)
      expect(meter.tariff_standing_charges.last.value).to eq(expected_standing_charge)
    end

    it "inserts new tariffs" do
      upserter.perform
      meter.reload
      expect(meter.tariff_prices.count).to eq(1)
      expect(meter.tariff_prices.last.prices[0]).to eq (expected_tiered_tariff)
      expect(meter.tariff_prices.last.prices[1]).to eq (0.15992)
    end

    it "logs counts of inserts and updates" do
      expect(import_log).to receive(:update).with(prices_imported: 1, prices_updated: 0)
      expect(import_log).to receive(:update).with(standing_charges_imported: 1, standing_charges_updated: 0)
      upserter.perform
    end

    context 'if readings already exist' do

      let!(:tariff_price_1) { create(:tariff_price, meter: meter, tariff_date: start_date - 2.days) }
      let!(:tariff_price_2) { create(:tariff_price, meter: meter, tariff_date: start_date - 1.day) }
      let!(:tariff_standing_charge_1) { create(:tariff_standing_charge, meter: meter, start_date: start_date - 2.days) }
      let!(:tariff_standing_charge_2) { create(:tariff_standing_charge, meter: meter, start_date: start_date - 1.day) }

      it "removes old prices and standing charges" do
        expect( meter.tariff_prices.count ).to eql 2
        expect( meter.tariff_standing_charges.count ).to eql 2
        upserter.perform
        expect( meter.tariff_prices.count ).to eql 1
        expect( meter.tariff_standing_charges.count ).to eql 1
        expect( meter.tariff_prices ).not_to include(tariff_price_1)
        expect( meter.tariff_prices ).not_to include(tariff_price_2)
        expect( meter.tariff_standing_charges ).not_to include(tariff_standing_charge_1)
        expect( meter.tariff_standing_charges ).not_to include(tariff_standing_charge_2)
      end
    end
  end
end
