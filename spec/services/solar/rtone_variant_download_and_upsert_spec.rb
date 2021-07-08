require 'rails_helper'

module Solar
  describe RtoneVariantDownloadAndUpsert do

    let(:meter)         { create(:electricity_meter) }
    let(:installation)  { create(:rtone_variant_installation, meter: meter)}

    let(:end_date)    { Date.today }
    let(:start_date)    { Date.today - 1 }

    let(:readings)      {
      {
        mpan_mprn:        meter.mpan_mprn,
        readings:         { start_date: OneDayAMRReading.new(meter.mpan_mprn, start_date, 'ORIG', nil, start_date, Array.new(48, 0.25)) },
        missing_readings: []
      }
    }

    let(:api)       { double("low-carbon-hub-api") }

    let(:requested_start_date) { nil }
    let(:requested_end_date) { nil }

    let(:upserter)  { Solar::RtoneVariantDownloadAndUpsert.new(rtone_variant_installation: installation, start_date: requested_start_date, end_date: requested_end_date)}

    before(:each) do
      expect(LowCarbonHubMeterReadings).to receive(:new).with(installation.username, installation.password).and_return(api)
    end

    it "should handle and log exceptions" do
      expect(api).to receive(:download_by_component).and_raise(StandardError)
      upserter.perform
      expect( AmrDataFeedImportLog.count ).to eql 1
      expect( AmrDataFeedImportLog.first.error_messages ).to_not be_blank
    end

    context "when a date window is given" do
      let(:requested_start_date) { start_date }
      let(:requested_end_date) { end_date }

      before(:each) do
        expect(api).to receive(:download_by_component).with(installation.rtone_meter_id, installation.rtone_component_type, installation.meter.mpan_mprn, requested_start_date, requested_end_date).and_return(readings)
      end

      it "should use that" do
        upserter.perform
      end

      it "should insert data" do
        expect{ upserter.perform }.to change(AmrDataFeedReading, :count).by(1)
      end
    end

    context "when there are existing readings" do
      let!(:reading) {
        create(:amr_data_feed_reading, reading_date: reading_date,
        meter: meter)
      }

      before(:each) do
        expect(api).to receive(:download_by_component).with(installation.rtone_meter_id, installation.rtone_component_type, installation.meter.mpan_mprn, expected_start, expected_end).and_return(readings)
      end

      context "and they are old" do
        let(:reading_date)  { Date.yesterday - 20 }
        let(:expected_start) { reading_date }
        let(:expected_end) { Date.yesterday }

        it "should use last reading date as start" do
          upserter.perform
        end
      end
      context "and they are recent" do
        let(:reading_date)  { Date.yesterday }
        let(:expected_start) { Date.yesterday - 5 }
        let(:expected_end) { Date.yesterday }
        it "should default to reloading last 6 days" do
          upserter.perform
        end
      end
    end

    context "when there are no readings" do
      let(:expected_end) { Date.yesterday }
      let(:expected_start) { Date.yesterday - 5 }

      it "should default to loading last 6 days" do
        expect(api).to receive(:download_by_component).with(installation.rtone_meter_id, installation.rtone_component_type, installation.meter.mpan_mprn, expected_start, expected_end).and_return(readings)
        upserter.perform
      end
    end

  end
end
