require 'rails_helper'

module Amr
  describe N3rgyTariffsDownloadAndUpsert do

    let(:n3rgy_api)           { double(:n3rgy_api) }
    let(:n3rgy_api_factory)   { double(:n3rgy_api_factory, data_api: n3rgy_api) }
    let(:earliest)            { Date.parse("2019-01-01") }
    let(:thirteen_months_ago) { Date.today - 13.months }
    let(:meter)               { create(:electricity_meter ) }
    let(:end_date)            { Date.today - 7 }
    let(:start_date)          { end_date - 8 }
    let(:yesterday)           { Date.today - 1 }

    context "when downloading data" do
      it "should handle and log exceptions" do
        expect( TariffImportLog.count ).to eql 0
        expect(n3rgy_api).to receive(:tariffs).and_raise(StandardError)
        upserter = Amr::N3rgyTariffsDownloadAndUpsert.new( n3rgy_api_factory: n3rgy_api_factory, meter: meter, start_date: start_date, end_date: end_date )
        upserter.perform
        expect( TariffImportLog.count ).to eql 1
        expect( TariffImportLog.first.error_messages ).to_not be_blank
      end

      it "should use specified start and end dates" do
        expect(n3rgy_api).to receive(:tariffs).with(meter.mpan_mprn, meter.meter_type, start_date, end_date)
        upserter = Amr::N3rgyTariffsDownloadAndUpsert.new( n3rgy_api_factory: n3rgy_api_factory, meter: meter, start_date: start_date, end_date: end_date )
        upserter.perform
      end

      it "should use available date range if no dates specified" do
        available_range = (earliest..yesterday)
        expect(n3rgy_api).to receive(:tariffs_available_date_range).with(meter.mpan_mprn, meter.fuel_type).and_return(available_range)
        expect(n3rgy_api).to receive(:tariffs).with(meter.mpan_mprn, meter.meter_type, earliest, yesterday)
        upserter = Amr::N3rgyTariffsDownloadAndUpsert.new( n3rgy_api_factory: n3rgy_api_factory, meter: meter, start_date: nil, end_date: nil )
        upserter.perform
      end

      it "should request 12 months if earliest data is unknown" do
        expect(n3rgy_api).to receive(:tariffs_available_date_range).with(meter.mpan_mprn, meter.fuel_type).and_return(nil)
        expect(n3rgy_api).to receive(:tariffs).with(meter.mpan_mprn, meter.meter_type, thirteen_months_ago, yesterday)
        upserter = Amr::N3rgyTariffsDownloadAndUpsert.new( n3rgy_api_factory: n3rgy_api_factory, meter: meter, start_date: nil, end_date: nil )
        upserter.perform
      end

      context "when upserting data" do

        let(:tariffs)        { { abc: 123 } }

        it "should result in new readings" do
          expect(n3rgy_api).to receive(:tariffs).with(meter.mpan_mprn, meter.meter_type, start_date, end_date).and_return(tariffs)
          expect(N3rgyTariffsUpserter).to receive(:new).with(meter: meter, tariffs: tariffs, import_log: anything)
          upserter = Amr::N3rgyTariffsDownloadAndUpsert.new( n3rgy_api_factory: n3rgy_api_factory, meter: meter, start_date: start_date, end_date: end_date )
          upserter.perform
        end
      end
    end
  end
end
