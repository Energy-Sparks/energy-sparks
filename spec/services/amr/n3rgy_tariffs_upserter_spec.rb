require 'rails_helper'

module Amr
  describe N3rgyTariffsUpserter do

    let(:meter)           { create(:electricity_meter) }
    let(:end_date)     { Date.today }
    let(:start_date) { end_date - 1 }

    let(:expected_tiered_tariff)      { {:tariffs=>{1=>0.48527000000000003, 2=>0.16774}, :thresholds=>{1=>1000}, :type=>:tiered} }
    let(:expected_prices)             { [expected_tiered_tariff, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992] }
    let(:expected_standing_charge)    { 0.19541 }

    let(:tariffs)        {
      {
        kwh_tariffs: { start_date => expected_prices },
        standing_charges: { start_date => expected_standing_charge }
      }
    }
    let(:import_log)    { create(:tariff_import_log) }

    let(:upserter) { Amr::N3rgyTariffsUpserter.new(meter: meter, tariffs: tariffs, import_log: import_log) }

    it "inserts new standing charges" do
      expect( TariffStandingCharge.count ).to eql 0
      upserter.perform
      expect( TariffStandingCharge.count ).to eql 1
      expect( TariffStandingCharge.last.value ).to eql (expected_standing_charge)
    end

    it "inserts new tariffs" do
      expect( TariffPrice.count ).to eql 0
      upserter.perform
      expect( TariffPrice.count ).to eql 1
      expect( TariffPrice.last.prices[0] ).to eql (JSON.parse(expected_tiered_tariff.to_json))
      expect( TariffPrice.last.prices[1] ).to eql (0.15992)
    end

    it "logs counts of inserts and updates" do
      expect(import_log).to receive(:update).with(prices_imported: 1, prices_updated: 0)
      expect(import_log).to receive(:update).with(standing_charges_imported: 1, standing_charges_updated: 0)
      upserter.perform
    end

  end
end
