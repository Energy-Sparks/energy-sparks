require 'rails_helper'

module Amr
  describe N3rgyDownloadAndUpsert do

    let(:n3rgy_api)         { double("n3rgy_api") }
    let(:earliest)          { Date.parse("2019-01-01") }
    let(:twelve_months_ago) { Date.today - 12.months }
    let(:meter)             { create(:electricity_meter, earliest_available_data: earliest ) }
    let(:config)            { create(:amr_data_feed_config)}
    let(:end_date)          { Date.today }
    let(:start_date)        { end_date - 1 }
    let(:today)             { Date.today }

    let(:readings)        {
      {
        meter.meter_type => {
            mpan_mprn:        meter.mpan_mprn,
            readings:         { start_date: OneDayAMRReading.new(meter.mpan_mprn, start_date, 'ORIG', nil, start_date, Array.new(48, 0.25)) },
            missing_readings: []
          }
      }
    }

    context "when downloading data" do
      it "should handle and log exceptions" do
        expect(n3rgy_api).to receive(:readings).with(meter.mpan_mprn, meter.meter_type, start_date, end_date) do
          raise
        end
        upserter = Amr::N3rgyDownloadAndUpsert.new( n3rgy_api: n3rgy_api, config: config, meter: meter, start_date: start_date, end_date: end_date )
        upserter.perform
      end

      it "should use provided date window" do
        expect(n3rgy_api).to receive(:readings).with(meter.mpan_mprn, meter.meter_type, start_date, end_date) do
          readings
        end
        upserter = Amr::N3rgyDownloadAndUpsert.new( n3rgy_api: n3rgy_api, config: config, meter: meter, start_date: start_date, end_date: end_date )
        upserter.perform
      end

      it "should use earliest available data if no date window" do
        expect(n3rgy_api).to receive(:readings).with(meter.mpan_mprn, meter.meter_type, earliest, today) do
          readings
        end
        upserter = Amr::N3rgyDownloadAndUpsert.new( n3rgy_api: n3rgy_api, config: config, meter: meter, start_date: nil, end_date: nil )
        upserter.perform
      end

      it "should request 12 months if no earliest data is unknown and no readings" do
        expect(n3rgy_api).to receive(:readings).with(meter.mpan_mprn, meter.meter_type, twelve_months_ago, today) do
          readings
        end

        meter.update!({
          earliest_available_data: nil
        })

        upserter = Amr::N3rgyDownloadAndUpsert.new( n3rgy_api: n3rgy_api, config: config, meter: meter, start_date: nil, end_date: nil )
        upserter.perform
      end

      it "should request recent data, if there are readings" do

        last_week = Date.today - 7
        meter.update!({
          earliest_available_data: last_week
        })

        amr_data_feed_reading = create(:amr_data_feed_reading, meter: meter, reading_date: last_week)
        amr_data_feed_reading = create(:amr_data_feed_reading, meter: meter, reading_date: last_week+1)
        amr_data_feed_reading = create(:amr_data_feed_reading, meter: meter, reading_date: last_week+2)

        #most recent reading is for earliest available date, so start reading new data from there
        #which is 5 days ago
        expect(n3rgy_api).to receive(:readings).with(meter.mpan_mprn, meter.meter_type, last_week+2, today) do
          readings
        end

        upserter = Amr::N3rgyDownloadAndUpsert.new( n3rgy_api: n3rgy_api, config: config, meter: meter, start_date: nil, end_date: nil )
        upserter.perform
      end

      it "should backfill if there is a gap" do
        #reading date is yesterday
        amr_data_feed_reading = create(:amr_data_feed_reading, meter: meter, reading_date: Date.yesterday)
        #gap between most recent reading and earliest available data, so try re-reading
        expect(n3rgy_api).to receive(:readings).with(meter.mpan_mprn, meter.meter_type, earliest, today) do
          readings
        end

        upserter = Amr::N3rgyDownloadAndUpsert.new( n3rgy_api: n3rgy_api, config: config, meter: meter, start_date: nil, end_date: nil )
        upserter.perform

      end
    end


    context "when upserting data" do
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
end
