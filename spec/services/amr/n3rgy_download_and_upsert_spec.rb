require 'rails_helper'

module Amr
  describe N3rgyDownloadAndUpsert do

    let(:n3rgy_api)         { double(:n3rgy_api) }
    let(:n3rgy_api_factory) { double(:n3rgy_api_factory, data_api: n3rgy_api) }
    let(:earliest)          { Date.parse("2019-01-01") }
    let(:thirteen_months_ago) { Date.today - 13.months }
    let(:meter)             { create(:electricity_meter, earliest_available_data: earliest ) }
    let(:config)            { create(:amr_data_feed_config)}
    let(:end_date)          { Date.today - 7 }
    let(:start_date)        { end_date - 8 }
    let(:yesterday)             { Date.today - 1 }

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
        expect( AmrDataFeedImportLog.count ).to eql 0

        expect(n3rgy_api).to receive(:readings).with(meter.mpan_mprn, meter.meter_type, start_date, end_date) do
          raise
        end
        upserter = Amr::N3rgyDownloadAndUpsert.new( n3rgy_api_factory: n3rgy_api_factory, config: config, meter: meter, start_date: start_date, end_date: end_date )
        upserter.perform
        expect( AmrDataFeedImportLog.count ).to eql 1
        expect( AmrDataFeedImportLog.first.error_messages ).to_not be_blank
      end

      it "should use provided date window" do
        expect(n3rgy_api).to receive(:readings).with(meter.mpan_mprn, meter.meter_type, start_date, end_date) do
          readings
        end
        upserter = Amr::N3rgyDownloadAndUpsert.new( n3rgy_api_factory: n3rgy_api_factory, config: config, meter: meter, start_date: start_date, end_date: end_date )
        upserter.perform
      end

      it "should use earliest available data if no date window" do
        expect(n3rgy_api).to receive(:readings).with(meter.mpan_mprn, meter.meter_type, earliest, yesterday) do
          readings
        end
        upserter = Amr::N3rgyDownloadAndUpsert.new( n3rgy_api_factory: n3rgy_api_factory, config: config, meter: meter, start_date: nil, end_date: nil )
        upserter.perform
      end

      it "should request 12 months if no earliest data is unknown and no readings" do
        expect(n3rgy_api).to receive(:readings).with(meter.mpan_mprn, meter.meter_type, thirteen_months_ago, yesterday) do
          readings
        end

        meter.update!({
          earliest_available_data: nil
        })

        upserter = Amr::N3rgyDownloadAndUpsert.new( n3rgy_api_factory: n3rgy_api_factory, config: config, meter: meter, start_date: nil, end_date: nil )
        upserter.perform
      end

      context "when there are readings" do

        let(:last_week) { Date.today - 7 }

        before do
          create(:amr_data_feed_reading, meter: meter, reading_date: last_week)
          create(:amr_data_feed_reading, meter: meter, reading_date: last_week+1)
          create(:amr_data_feed_reading, meter: meter, reading_date: last_week+2)
        end

        it "should request data from available data date if that was earlier than current first reading" do
          meter.update!(earliest_available_data: last_week - 1)
          expect(n3rgy_api).to receive(:readings).with(meter.mpan_mprn, meter.meter_type, last_week-1, yesterday) do
            readings
          end

          upserter = Amr::N3rgyDownloadAndUpsert.new( n3rgy_api_factory: n3rgy_api_factory, config: config, meter: meter, start_date: nil, end_date: nil )
          upserter.perform
        end

        it "should request data from current last reading if first reading is earlier than earliest_available_data" do
          meter.update!(earliest_available_data: last_week)
          expect(n3rgy_api).to receive(:readings).with(meter.mpan_mprn, meter.meter_type, last_week+2, yesterday) do
            readings
          end

          upserter = Amr::N3rgyDownloadAndUpsert.new( n3rgy_api_factory: n3rgy_api_factory, config: config, meter: meter, start_date: nil, end_date: nil )
          upserter.perform
        end

        it "should request data from last reading date if no earliest_available_data" do
          meter.update!(earliest_available_data: nil)
          expect(n3rgy_api).to receive(:readings).with(meter.mpan_mprn, meter.meter_type, last_week+2, yesterday) do
            readings
          end

          upserter = Amr::N3rgyDownloadAndUpsert.new( n3rgy_api_factory: n3rgy_api_factory, config: config, meter: meter, start_date: nil, end_date: nil )
          upserter.perform
        end
      end
    end

    context "when upserting data" do
      it "should result in new readings" do
        expect(n3rgy_api).to receive(:readings).with(meter.mpan_mprn, meter.meter_type, start_date, end_date) do
          readings
        end
        upserter = Amr::N3rgyDownloadAndUpsert.new( n3rgy_api_factory: n3rgy_api_factory, config: config, meter: meter, start_date: start_date, end_date: end_date )
        upserter.perform

        expect( AmrDataFeedImportLog.count ).to eql 1
        expect( AmrDataFeedReading.count ).to eql 1
      end
    end
  end
end
