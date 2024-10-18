require 'rails_helper'

module Solar
  describe LowCarbonHubDownloadAndUpsert do
    let!(:school)               { create(:school) }
    let(:rbee_meter_id)         { '216057958' }
    let(:meter)         { create(:electricity_meter, low_carbon_hub_installation: installation, mpan_mprn: 90000000123085, pseudo: true, name: 'Test', school: school) }

    let(:installation)  { create(:low_carbon_hub_installation, rbee_meter_id: rbee_meter_id, school: school)}

    let(:start_date)            { Date.parse('02/08/2016') }
    let(:end_date)              { start_date + 1.day }

    let(:readings)              do
      {
        solar_pv: {
          mpan_mprn: 70000000123085,
          readings: {
            start_date => OneDayAMRReading.new(70000000123085, start_date, 'ORIG', nil, start_date, Array.new(48, 0.25)),
            end_date => OneDayAMRReading.new(70000000123085, end_date, 'ORIG', nil, end_date, Array.new(48, 0.5))
          }
        },
        electricity: {
          mpan_mprn: 90000000123085,
          readings: {
            start_date => OneDayAMRReading.new(90000000123085, start_date, 'ORIG', nil, start_date, Array.new(48, 0.25)),
            end_date => OneDayAMRReading.new(90000000123085, end_date, 'ORIG', nil, end_date, Array.new(48, 0.5))
          }
        },
        exported_solar_pv: {
          mpan_mprn: 60000000123085,
          readings: {
            start_date => OneDayAMRReading.new(60000000123085, start_date, 'ORIG', nil, start_date, Array.new(48, 0.25)),
            end_date => OneDayAMRReading.new(60000000123085, end_date, 'ORIG', nil, end_date, Array.new(48, 0.5))
          }
        },
      }
    end

    let(:api) { double('low_carbon_hub_api') }

    let(:requested_start_date) { nil }
    let(:requested_end_date) { nil }

    let(:upserter) { Solar::LowCarbonHubDownloadAndUpsert.new(installation: installation, start_date: requested_start_date, end_date: requested_end_date)}

    before do
      expect(DataFeeds::LowCarbonHubMeterReadings).to receive(:new).with(installation.username, installation.password).and_return(api)
    end

    it 'handles and log exceptions' do
      expect(api).to receive(:download).and_raise(StandardError)
      upserter.perform
      expect(AmrDataFeedImportLog.count).to be 1
      expect(AmrDataFeedImportLog.first.error_messages).not_to be_blank
    end

    context 'when a date window is given' do
      let(:requested_start_date) { requested_end_date - 1 }
      let(:requested_end_date) { Time.zone.today }

      before do
        expect(api).to receive(:download).with(installation.rbee_meter_id,
          installation.school.urn, requested_start_date, requested_end_date).and_return(readings)
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
      let!(:reading) do
        create(:amr_data_feed_reading, reading_date: reading_date,
        meter: meter)
      end

      before do
        expect(api).to receive(:download).with(installation.rbee_meter_id,
          installation.school.urn, expected_start, expected_end).and_return(readings)
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

        it 'inserts data' do
          expect(AmrDataFeedReading.count).to be 1
          upserter.perform
          expect(AmrDataFeedReading.count).to be 7
        end
      end
    end

    context 'when there are no readings' do
      let(:expected_end) { Date.yesterday }
      let(:expected_start) { nil }

      it 'loads all data' do
        expect(api).to receive(:download).with(installation.rbee_meter_id,
          installation.school.urn, expected_start, expected_end).and_return(readings)
        upserter.perform
      end
    end
  end
end
