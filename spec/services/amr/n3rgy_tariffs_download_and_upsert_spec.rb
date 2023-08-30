require 'rails_helper'

module Amr
  describe N3rgyTariffsDownloadAndUpsert do

    let(:n3rgy_api)           { double(:n3rgy_api) }
    let(:n3rgy_api_factory)   { double(:n3rgy_api_factory, data_api: n3rgy_api) }
    let(:meter)               { create(:electricity_meter ) }
    let(:end_date)            { DateTime.now.beginning_of_day }
    let(:start_date)          { DateTime.now.yesterday.beginning_of_day }
    let(:expected_tiered_tariff)      { {:tariffs=>{1=>0.48527000000000003, 2=>0.16774}, :thresholds=>{1=>1000}, :type=>:tiered} }
    let(:expected_prices)             { [0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992, 0.15992] }
    let(:expected_standing_charge)    { 0.19541 }
    let(:kwh_tariffs)                 { { start_date => expected_prices } }
    let(:standing_charges)            { { start_date => expected_standing_charge } }
    let(:tariffs)                     { { kwh_tariffs: kwh_tariffs, standing_charges: standing_charges } }

    let(:zero_kwh_tariffs)                 { { start_date => Array.new(48, 0.0) } }
    let(:zero_standing_charges)            { { start_date => 0.0 } }
    let(:zero_tariffs)                     { { kwh_tariffs: zero_kwh_tariffs, standing_charges: zero_standing_charges } }

    before { TariffImportLog.delete_all }

    context "when downloading data" do
      it "should handle and log exceptions" do
        expect(TariffImportLog.count).to eq(0)
        expect(n3rgy_api).to receive(:tariffs).and_raise(StandardError)
        expect {
          Amr::N3rgyTariffsDownloadAndUpsert.new( n3rgy_api_factory: n3rgy_api_factory, meter: meter ).perform
        }.to change { TariffImportLog.count }.by(1)
         .and change { TariffPrice.count }.by(0)
         .and change { TariffStandingCharge.count }.by(0)
        expect(TariffImportLog.first.error_messages).to eq("Error downloading tariffs from #{start_date} to #{end_date} : StandardError")
      end

      it "should request 24 hours of data and upsert a new tariff price and tariff standing charge if there are no existing records of the same date" do
        allow(n3rgy_api).to receive(:tariffs).with(meter.mpan_mprn, meter.meter_type, start_date, end_date).and_return(tariffs)
        expect(TariffImportLog.count).to eq(0)
        expect {
          Amr::N3rgyTariffsDownloadAndUpsert.new(n3rgy_api_factory: n3rgy_api_factory, meter: meter).perform
        }.to change { TariffImportLog.count }.by(1)
         .and change { TariffPrice.count }.by(1)
         .and change { TariffStandingCharge.count }.by(1)
        expect(TariffImportLog.first.error_messages).to be_blank

        # Should not insert new records if they already exist
        expect {
          Amr::N3rgyTariffsDownloadAndUpsert.new(n3rgy_api_factory: n3rgy_api_factory, meter: meter).perform
        }.to change { TariffImportLog.count }.by(1)
         .and change { TariffPrice.count }.by(0)
         .and change { TariffStandingCharge.count }.by(0)
        expect(TariffImportLog.last.error_messages).to be_blank
      end

      it "should request 24 hours of data but not upsert a new tariff price and tariff standing charge if there are zero tariffs but should log an error " do
        allow(n3rgy_api).to receive(:tariffs).with(meter.mpan_mprn, meter.meter_type, start_date, end_date).and_return(zero_tariffs)
        expect(TariffImportLog.count).to eq(0)
        expect {
          Amr::N3rgyTariffsDownloadAndUpsert.new(n3rgy_api_factory: n3rgy_api_factory, meter: meter).perform
        }.to change { TariffImportLog.count }.by(1)
         .and change { TariffPrice.count }.by(0)
         .and change { TariffStandingCharge.count }.by(0)
        expect(TariffImportLog.first.error_messages).to eq("Error downloading tariffs: prices returned from n3rgy for #{start_date} are zero and standing charges returned from n3rgy for #{start_date} are zero")
      end
    end
  end
end
