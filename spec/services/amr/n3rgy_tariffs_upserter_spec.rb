require 'rails_helper'

module Amr
  describe N3rgyTariffsUpserter do
    let(:meter)                       { create(:electricity_meter) }
    let(:end_date)                    { Date.today }
    let(:start_date)                  { end_date - 1 }

    let(:import_log)                  { create(:tariff_import_log) }

    let(:expected_tiered_tariff)      { { :tariffs => { 1 => 0.48527000000000003, 2 => 0.16774 }, :thresholds => { 1 => 1000 }, :type => :tiered } }
    let(:expected_prices)             { [expected_tiered_tariff, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992] }
    let(:expected_standing_charge)    { 0.19541 }

    let(:kwh_tariffs)                 { { start_date => expected_prices } }
    let(:standing_charges)            { { start_date => expected_standing_charge } }

    let(:tariffs)                     { { kwh_tariffs: kwh_tariffs, standing_charges: standing_charges } }

    let(:upserter) { Amr::N3rgyTariffsUpserter.new(meter: meter, tariffs: tariffs, import_log: import_log) }

    context 'with empty prices' do
      let(:kwh_tariffs) { {} }

      it "skips upsert" do
        upserter.perform
        expect(meter.reload.tariff_prices.count).to eq(0)
      end
    end

    context 'with empty standing charges' do
      let(:standing_charges) { {} }

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
      expect(meter.tariff_prices.last.prices[0]).to eq expected_tiered_tariff
      expect(meter.tariff_prices.last.prices[1]).to eq 0.15992
    end

    it "logs counts of inserts and updates" do
      expect(import_log).to receive(:update).with(prices_imported: 1, prices_updated: 0)
      expect(import_log).to receive(:update).with(standing_charges_imported: 1, standing_charges_updated: 0)
      upserter.perform
    end

    context 'if readings already exist' do
      it "adds a new price array if it differs from the latest" do
        tariffs_1 = {
          kwh_tariffs: { (Date.today - 3.days) => [{ :tariffs => {1 => 0.48527000000000003, 2 => 0.16774}, :thresholds => {1 => 1000}, :type => :tiered}, 0.11992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992] }, standing_charges: {Date.today - 3.days => 0.19541}
        }

        tariffs_2 = {
          kwh_tariffs: { (Date.today - 2.days) => [{:tariffs => {1 => 0.48527000000000003, 2 => 0.16774}, :thresholds => {1 => 1000}, :type => :tiered}, 0.12992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992]}, standing_charges: {Date.today - 2.days => 0.19541}
        }

        tariffs_3 = {
          kwh_tariffs: { (Date.today - 1.day) => [{:tariffs => {1 => 0.48527000000000003, 2 => 0.16774}, :thresholds => {1 => 1000}, :type => :tiered}, 0.13992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992]}, standing_charges: {Date.today - 1.day => 0.19541}
        }

        tariffs_4 = {
          kwh_tariffs: { Date.today => [{:tariffs => {1 => 0.48527000000000003, 2 => 0.16774}, :thresholds => {1 => 1000}, :type => :tiered}, 0.13992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992]}, standing_charges: {Date.today - 1.day => 0.19541}
        }

        tariffs_5 = {
          kwh_tariffs: { Date.today => [{:tariffs => {1 => 0.48527000000000003, 2 => 0.16774}, :thresholds => {1 => 1000}, :type => :tiered}, 0.11992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992]}, standing_charges: {Date.today => 0.19541}
        }

        expect(TariffPrice.count).to eq(0)
        expect(TariffStandingCharge.count).to eq(0)
        Amr::N3rgyTariffsUpserter.new(meter: meter, tariffs: tariffs_1, import_log: import_log).perform
        expect(TariffPrice.count).to eq(1)
        expect(TariffStandingCharge.count).to eq(1)
        Amr::N3rgyTariffsUpserter.new(meter: meter, tariffs: tariffs_2, import_log: import_log).perform
        expect(TariffPrice.count).to eq(2)
        expect(TariffStandingCharge.count).to eq(2)
        Amr::N3rgyTariffsUpserter.new(meter: meter, tariffs: tariffs_3, import_log: import_log).perform
        expect(TariffPrice.count).to eq(3)
        expect(TariffStandingCharge.count).to eq(3)
        # These two tariffs are already in the database so a
        Amr::N3rgyTariffsUpserter.new(meter: meter, tariffs: tariffs_1, import_log: import_log).perform
        Amr::N3rgyTariffsUpserter.new(meter: meter, tariffs: tariffs_2, import_log: import_log).perform
        expect(TariffPrice.count).to eq(3)
        expect(TariffStandingCharge.count).to eq(3)
        # This run has a pricing array identical to the last one stored
        Amr::N3rgyTariffsUpserter.new(meter: meter, tariffs: tariffs_4, import_log: import_log).perform
        expect(TariffPrice.count).to eq(3)
        expect(TariffStandingCharge.count).to eq(3)
        # This run has a pricing array different to the last one stored (tariffs_5 has the same date as tariffs_4)
        Amr::N3rgyTariffsUpserter.new(meter: meter, tariffs: tariffs_5, import_log: import_log).perform
        expect(TariffPrice.count).to eq(4)
        expect(TariffStandingCharge.count).to eq(4)
        Amr::N3rgyTariffsUpserter.new(meter: meter, tariffs: tariffs_5, import_log: import_log).perform
        expect(TariffPrice.count).to eq(4)
        expect(TariffStandingCharge.count).to eq(4)




        # expect( meter.tariff_prices.count ).to eql 2
        # expect( meter.tariff_standing_charges.count ).to eql 2
        # upserter.perform
        # expect( meter.tariff_prices.count ).to eql 3
        # expect( TariffPrice.count ).to eql 3
        # expect( meter.tariff_standing_charges.count ).to eql 3
        # expect( TariffStandingCharge.count ).to eql 3
        # # expect( meter.tariff_prices ).not_to include(tariff_price_1)
        # # expect( meter.tariff_prices ).not_to include(tariff_price_2)
        # # expect( meter.tariff_standing_charges ).not_to include(tariff_standing_charge_1)
        # # expect( meter.tariff_standing_charges ).not_to include(tariff_standing_charge_2)
      end
    end
  end
end
