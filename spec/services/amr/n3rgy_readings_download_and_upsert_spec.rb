require 'rails_helper'

module Amr
  describe N3rgyReadingsDownloadAndUpsert do

    let(:n3rgy_api)         { double(:n3rgy_api) }
    let(:n3rgy_api_factory) { double(:n3rgy_api_factory, data_api: n3rgy_api) }
    let(:earliest)          { Date.parse("2019-01-01") }
    let(:meter)             { create(:electricity_meter, earliest_available_data: earliest ) }
    let(:config)            { create(:amr_data_feed_config)}
    let(:end_date)          { Date.today.yesterday.end_of_day }
    let(:start_date)        { Date.today.yesterday.beginning_of_day }

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
        allow(n3rgy_api).to receive(:readings_available_date_range).with(meter.mpan_mprn, meter.fuel_type).and_return(Time.zone.now-10.days..Time.zone.now)
        expect( AmrDataFeedImportLog.count ).to eq(0)
        expect(n3rgy_api).to receive(:readings).and_raise(StandardError)
        expect {
          Amr::N3rgyReadingsDownloadAndUpsert.new(n3rgy_api_factory: n3rgy_api_factory, config: config, meter: meter).perform
        }.to change { AmrDataFeedImportLog.count }.by(1).and change { AmrDataFeedReading.count }.by(0)
        expect(AmrDataFeedImportLog.first.error_messages).to_not be_blank
      end

      it "should request 24 hours of data and create a new AmrDataFeedReading if readings are available" do
        allow(n3rgy_api).to receive(:readings_available_date_range).with(meter.mpan_mprn, meter.fuel_type).and_return(Time.zone.now-10.days..Time.zone.now)
        allow(n3rgy_api).to receive(:readings).with(meter.mpan_mprn, meter.meter_type, Date.today.yesterday.beginning_of_day, Date.today.yesterday.end_of_day).and_return(readings)
        expect do
          Amr::N3rgyReadingsDownloadAndUpsert.new(
            n3rgy_api_factory: n3rgy_api_factory,
            config: config,
            meter: meter
          ).perform
        end.to change { AmrDataFeedImportLog.count }.by(1).and change { AmrDataFeedReading.count }.by(1)
      end

      it "should request 24 hours of data and *update* an existing AmrDataFeedReading of the same if readings are available" do
      end

      it 'should request 24 hours of data and *not* create a new AmrDataFeedReading if readings are not available' do
        allow(n3rgy_api).to receive(:readings_available_date_range).with(meter.mpan_mprn, meter.fuel_type).and_return(Time.zone.now-10.days..Time.zone.now-2.days)
        allow(n3rgy_api).to receive(:readings).with(meter.mpan_mprn, meter.meter_type, Date.today.yesterday.beginning_of_day, Date.today.yesterday.end_of_day).and_return(readings)
        expect do
          Amr::N3rgyReadingsDownloadAndUpsert.new(
            n3rgy_api_factory: n3rgy_api_factory,
            config: config,
            meter: meter
          ).perform
        end.to change { AmrDataFeedImportLog.count }.by(0).and change { AmrDataFeedReading.count }.by(0)
      end
    end

    describe '#readings' do
      it 'should return the last 24 hours readings for a given meter' do
        allow(n3rgy_api).to receive(:readings_available_date_range).with(meter.mpan_mprn, meter.fuel_type).and_return(Time.zone.now-10.days..Time.zone.now)
        allow(n3rgy_api).to receive(:readings).with(meter.mpan_mprn, meter.meter_type, Date.today.yesterday.beginning_of_day, Date.today.yesterday.end_of_day).and_return(readings)
        expect(
          Amr::N3rgyReadingsDownloadAndUpsert.new(
            n3rgy_api_factory: n3rgy_api_factory,
            config: config,
            meter: meter
          ).send(:readings)
        ).to eq(readings)
      end
    end
  end
end
