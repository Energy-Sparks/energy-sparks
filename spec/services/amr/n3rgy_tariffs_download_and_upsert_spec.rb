require 'rails_helper'

module Amr
  describe N3rgyTariffsDownloadAndUpsert do

    let(:n3rgy_api)           { double(:n3rgy_api) }
    let(:n3rgy_api_factory)   { double(:n3rgy_api_factory, data_api: n3rgy_api) }
    let(:earliest)            { Date.parse("2019-01-01") }
    let(:thirteen_months_ago) { Date.today - 13.months }
    let(:meter)               { create(:electricity_meter ) }
    let(:end_date)            { Date.today.yesterday.end_of_day }
    let(:start_date)          { Date.today.yesterday.beginning_of_day }
    let(:yesterday)           { Date.today - 1 }

    context "when downloading data" do
      it "should handle and log exceptions" do
        expect( TariffImportLog.count ).to eql 0
        expect(n3rgy_api).to receive(:tariffs).and_raise(StandardError)
        expect {
          Amr::N3rgyTariffsDownloadAndUpsert.new( n3rgy_api_factory: n3rgy_api_factory, meter: meter ).perform
        }.to change { TariffImportLog.count }.by(1)
         .and change { TariffPrice.count }.by(0)
         .and change { TariffPrice.count }.by(0)
         .and change { TariffStandingCharge.count }.by(0)


        expect(TariffImportLog.first.error_messages).to_not be_blank
      end

      it "should use specified start and end dates" do
        expect(n3rgy_api).to receive(:tariffs).with(meter.mpan_mprn, meter.meter_type, start_date, end_date)
        upserter = Amr::N3rgyTariffsDownloadAndUpsert.new( n3rgy_api_factory: n3rgy_api_factory, meter: meter )
        upserter.perform
      end

      it "should use available date range if no dates specified" do
        available_range = (earliest..yesterday)
        expect(n3rgy_api).to receive(:tariffs).with(meter.mpan_mprn, meter.meter_type, Date.today.yesterday.beginning_of_day, Date.today.yesterday.end_of_day)
        upserter = Amr::N3rgyTariffsDownloadAndUpsert.new( n3rgy_api_factory: n3rgy_api_factory, meter: meter )
        upserter.perform
      end

      it "should request 24 hours if earliest data is unknown" do
        # expect(n3rgy_api).to receive(:tariffs_available_date_range).with(meter.mpan_mprn, meter.fuel_type).and_return(nil)
        expect(n3rgy_api).to receive(:tariffs).with(meter.mpan_mprn, meter.meter_type, Date.today.yesterday.beginning_of_day, Date.today.yesterday.end_of_day)
        upserter = Amr::N3rgyTariffsDownloadAndUpsert.new( n3rgy_api_factory: n3rgy_api_factory, meter: meter )
        upserter.perform
      end

      context "when upserting data" do

        let(:tariffs)        { { abc: 123 } }

        it "should result in new readings" do
          expect(n3rgy_api).to receive(:tariffs).with(meter.mpan_mprn, meter.meter_type, start_date, end_date).and_return(tariffs)
          expect(N3rgyTariffsUpserter).to receive(:new).with(meter: meter, tariffs: tariffs, import_log: anything)
          upserter = Amr::N3rgyTariffsDownloadAndUpsert.new( n3rgy_api_factory: n3rgy_api_factory, meter: meter )
          upserter.perform
        end
      end
    end
  end
end
