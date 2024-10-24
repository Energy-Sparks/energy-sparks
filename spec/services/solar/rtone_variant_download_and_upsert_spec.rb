require 'rails_helper'

module Solar
  describe RtoneVariantDownloadAndUpsert do
    let(:meter)         { create(:electricity_meter) }
    let(:installation)  { create(:rtone_variant_installation, meter: meter)}

    let(:end_date) { Time.zone.today }
    let(:start_date)    { Time.zone.today - 1 }

    let(:readings)      do
      {
        mpan_mprn:        meter.mpan_mprn,
        readings:         { start_date: OneDayAMRReading.new(meter.mpan_mprn, start_date, 'ORIG', nil, start_date, Array.new(48, 0.25)) },
        missing_readings: []
      }
    end

    let(:api) { double('low-carbon-hub-api') }

    let(:requested_start_date) { nil }
    let(:requested_end_date) { nil }

    let(:upserter) { Solar::RtoneVariantDownloadAndUpsert.new(installation: installation, start_date: requested_start_date, end_date: requested_end_date)}

    before do
      expect(DataFeeds::LowCarbonHubMeterReadings).to receive(:new).with(installation.username, installation.password).and_return(api)
    end

    it 'handles and log exceptions' do
      expect(api).to receive(:download_by_component).and_raise(StandardError)
      upserter.perform
      expect(AmrDataFeedImportLog.count).to be 1
      expect(AmrDataFeedImportLog.first.error_messages).not_to be_blank
    end

    context 'when a date window is given' do
      let(:requested_start_date) { start_date }
      let(:requested_end_date) { end_date }

      before do
        expect(api).to receive(:download_by_component).with(installation.rtone_meter_id, installation.rtone_component_type, installation.meter.mpan_mprn, requested_start_date, requested_end_date).and_return(readings)
      end

      it 'uses that' do
        upserter.perform
      end

      it 'inserts data' do
        expect(AmrDataFeedReading.count).to be 0
        upserter.perform
        expect(AmrDataFeedReading.count).to be 1
      end
    end

    context 'when there are existing readings' do
      let!(:reading) do
        create(:amr_data_feed_reading, reading_date: reading_date,
        meter: meter)
      end

      before do
        expect(api).to receive(:download_by_component).with(installation.rtone_meter_id, installation.rtone_component_type, installation.meter.mpan_mprn, expected_start, expected_end).and_return(readings)
      end

      context 'and they are old' do
        let(:reading_date)  { Date.yesterday - 20 }
        let(:expected_start) { reading_date }
        let(:expected_end) { Date.yesterday }

        it 'uses last reading date as start' do
          upserter.perform
        end
      end

      context 'and they are recent' do
        let(:reading_date)  { Date.yesterday }
        let(:expected_start) { Date.yesterday - 5 }
        let(:expected_end) { Date.yesterday }

        it 'defaults to reloading last 6 days' do
          upserter.perform
        end
      end
    end

    context 'when there are no readings' do
      let(:expected_end) { Date.yesterday }
      let(:expected_start) { nil }

      it 'loads all readings' do
        expect(api).to receive(:download_by_component).with(installation.rtone_meter_id, installation.rtone_component_type, installation.meter.mpan_mprn, expected_start, expected_end).and_return(readings)
        upserter.perform
      end
    end
  end
end
