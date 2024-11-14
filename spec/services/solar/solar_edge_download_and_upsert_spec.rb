require 'rails_helper'

module Solar
  describe SolarEdgeDownloadAndUpsert do
    let(:mpan) { 1112223334445 }
    let(:installation) { create(:solar_edge_installation, mpan: mpan)}

    let(:solar_pv_readings)           { { 'Sun, 29 Nov 2020' => Array.new(48, 1.0), 'Mon, 30 Nov 2020' => Array.new(48, 2.0) } }
    let(:electricity_readings)        { { 'Sun, 29 Nov 2020' => Array.new(48, 3.0), 'Mon, 30 Nov 2020' => Array.new(48, 4.0) } }
    let(:exported_solar_pv_readings)  { { 'Sun, 29 Nov 2020' => Array.new(48, 5.0), 'Mon, 30 Nov 2020' => Array.new(48, 6.0) } }

    let(:readings) do
      {
        :solar_pv =>          { :readings => solar_pv_readings },
        :electricity =>       { :readings => electricity_readings },
        :exported_solar_pv => { :readings => exported_solar_pv_readings }
      }
    end

    let(:api) { double('solar-edge-api') }

    let(:requested_start_date) { nil }
    let(:requested_end_date) { nil }

    let(:upserter) { Solar::SolarEdgeDownloadAndUpsert.new(installation: installation, start_date: requested_start_date, end_date: requested_end_date)}

    before do
      expect(DataFeeds::SolarEdgeApi).to receive(:new).with(installation.api_key).and_return(api)
    end

    it 'handles and log exceptions' do
      expect(api).to receive(:smart_meter_data).and_raise(StandardError)
      upserter.perform
      expect(AmrDataFeedImportLog.count).to be 1
      expect(AmrDataFeedImportLog.first.error_messages).not_to be_blank
    end

    context 'when a date window is given' do
      let(:requested_start_date) { requested_end_date - 1 }
      let(:requested_end_date) { Time.zone.today }

      before do
        expect(api).to receive(:smart_meter_data).with(installation.site_id, requested_start_date, requested_end_date).and_return(readings)
      end

      it 'uses that' do
        upserter.perform
      end

      it 'inserts data' do
        expect(AmrDataFeedReading.count).to be 0
        upserter.perform
        expect(AmrDataFeedReading.count).to be 6
      end
    end

    context 'when there are existing readings' do
      let(:meter) { create(:electricity_meter, mpan_mprn: "9#{mpan}".to_i, solar_edge_installation: installation)}
      let!(:reading) do
        create(:amr_data_feed_reading, reading_date: reading_date,
        meter: meter)
      end

      before do
        expect(api).to receive(:smart_meter_data).with(installation.site_id, expected_start, expected_end).and_return(readings)
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

      it 'loads all data' do
        expect(api).to receive(:smart_meter_data).with(installation.site_id, expected_start, expected_end).and_return(readings)
        upserter.perform
      end
    end
  end
end
