require 'rails_helper'

module Amr
  describe N3rgyDownloadAndUpsert do

    let(:n3rgy_api)   { double("n3rgy_api") }
    let(:meter)       { create(:electricity_meter) }
    let(:config)      { create(:amr_data_feed_config)}
    let(:end_date)    { Date.today }
    let(:start_date)  { end_date - 1 }
    let(:readings)        {
      {
        meter.meter_type => {
            mpan_mprn:        meter.mpan_mprn,
            readings:         { start_date: OneDayAMRReading.new(meter.mpan_mprn, start_date, 'ORIG', nil, start_date, Array.new(48, 0.25)) },
            missing_readings: []
          }
      }
    }

    it "should call the API" do
      expect(n3rgy_api).to receive(:readings).with(meter.mpan_mprn, meter.meter_type, nil, nil) do
        readings
      end
      upserter = Amr::N3rgyDownloadAndUpsert.new( n3rgy_api: n3rgy_api, config: config, meter: meter, start_date: nil, end_date: nil )
      upserter.perform
    end

    it "should result in new readings" do
      expect(n3rgy_api).to receive(:readings).with(meter.mpan_mprn, meter.meter_type, start_date, end_date) do
        readings
      end
      upserter = Amr::N3rgyDownloadAndUpsert.new( n3rgy_api: n3rgy_api, config: config, meter: meter, start_date: start_date, end_date: end_date )
      upserter.perform

      expect( AmrDataFeedImportLog.count ).to eql 1
      expect( AmrDataFeedReading.count ).to eql 1
    end
  end
end
