require 'rails_helper'

module Amr
  describe N3rgyReadingsDownloadAndUpsert do
    subject(:upserter) do
      described_class.new(config: create(:amr_data_feed_config),
        meter: meter,
        start_date: nil,
        end_date: nil)
    end

    let(:meter) { create(:electricity_meter) }

    let(:downloader) { instance_double(Amr::N3rgyDownloader) }
    let(:thirteen_months_ago) { DateTime.now - 13.months }
    let(:yesterday) { DateTime.now - 1 }

    before do
      allow(Amr::N3rgyDownloader).to receive(:new).and_return(downloader)
    end

    describe '#perform' do
      context 'with an error downloading data' do
        it 'handles and log exceptions' do
          expect(AmrDataFeedImportLog.count).to be 0
          allow(downloader).to receive(:readings).and_raise(StandardError)
          upserter.perform
          expect(AmrDataFeedImportLog.count).to be 1
          expect(AmrDataFeedImportLog.first.error_messages).not_to be_blank
        end
      end

      context 'when start and end dates are provided' do
        let(:end_date)          { DateTime.now - 7 }
        let(:start_date)        { end_date - 8 }

        subject(:upserter) do
          described_class.new(config: create(:amr_data_feed_config),
            meter: meter,
            start_date: start_date,
            end_date: end_date)
        end
        it 'uses those dates' do
          expect(Amr::N3rgyDownloader).to receive(:new).with(
            meter: meter,
            start_date: start_date,
            end_date: end_date
          )
          allow(downloader).to receive(:readings).and_return({})
          upserter.perform
        end
      end

      context 'when no specific dates are given' do
        before do
          metering_service_stub = double('metering-service')
          allow(Meters::N3rgyMeteringService).to receive(:new).and_return(metering_service_stub)
          allow(metering_service_stub).to receive(:available_data).and_return(available_data)
          allow(downloader).to receive(:readings).and_return({})
        end

        context 'with available data in n3rgy' do
          let(:earliest) { DateTime.parse('2019-01-01T00:00') }

          let(:available_data) do
            (earliest..yesterday)
          end

          it 'loads all available data if no dates specified' do
            expect(Amr::N3rgyDownloader).to receive(:new).with(
              meter: meter,
              start_date: earliest,
              end_date: yesterday
            )
            expect(downloader).to receive(:readings)
            upserter.perform
          end
        end

        context 'with no other dates available' do
          let(:available_data) { nil }

          it 'requests 12 months by default' do
            expect(Amr::N3rgyDownloader).to receive(:new).with(
              meter: meter,
              start_date: thirteen_months_ago,
              end_date: yesterday
            )
            expect(downloader).to receive(:readings)
            upserter.perform
          end
        end
      end

      context 'when there is data in the database' do
        # Note: this is a Date object as the reading date needs to be stored in the database in ISO 8601 format e.g. 2023-06-29
        let(:last_week) { Time.zone.today - 7 }

        before do
          create(:amr_data_feed_reading, meter: meter, reading_date: last_week)
          create(:amr_data_feed_reading, meter: meter, reading_date: last_week + 1)
          create(:amr_data_feed_reading, meter: meter, reading_date: last_week + 2)
        end

        let(:end_date)          { DateTime.now - 7 }
        let(:start_date)        { end_date - 8 }

        let(:readings) do
          {
            meter.meter_type => {
                mpan_mprn:        meter.mpan_mprn,
                readings:         { start_date => OneDayAMRReading.new(meter.mpan_mprn, start_date, 'ORIG', nil, start_date, Array.new(48, 0.25)) },
                missing_readings: []
              }
          }
        end

        before do
          metering_service_stub = double('metering-service')
          allow(Meters::N3rgyMeteringService).to receive(:new).and_return(metering_service_stub)
          allow(metering_service_stub).to receive(:available_data).and_return(available_data)
          allow(downloader).to receive(:readings).and_return(readings)
        end

        context 'with earlier data available from n3rgy' do
          let(:available_data) { (last_week - 1..yesterday) }

          it 'requests earlier data from n3rgy if they have data prior to the first reading' do
            # maximum and minimum amr data feed readings reading date should be in ISO 8601 format e.g. '2023-06-29'
            expect(meter.amr_data_feed_readings.minimum(:reading_date)).to match(/^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[1-2][0-9]|3[0-1])$/)
            expect(meter.amr_data_feed_readings.maximum(:reading_date)).to match(/^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[1-2][0-9]|3[0-1])$/)

            expect(Amr::N3rgyDownloader).to receive(:new).with(
              meter: meter,
              start_date: last_week - 1,
              end_date: yesterday
            )
            upserter.perform
          end
        end

        context 'with earlier data in our database' do
          let(:available_data) { (last_week..yesterday) }

          it 'requests newer data if we have the earliest readings' do
            expect(Amr::N3rgyDownloader).to receive(:new).with(
              meter: meter,
              start_date: last_week + 2,
              end_date: yesterday
            )
            upserter.perform
          end
        end

        context 'with no data from n3rgy' do
          let(:available_data) { nil }

          it 'requests data from 13 months ago if no date ranges available from n3rgy' do
            expect(Amr::N3rgyDownloader).to receive(:new).with(
              meter: meter,
              start_date: thirteen_months_ago,
              end_date: yesterday
            )
            upserter.perform
          end
        end
      end

      context 'when reading data is returned' do
        let(:readings) do
          {
            meter.meter_type => {
                mpan_mprn:        meter.mpan_mprn,
                readings:         { yesterday => OneDayAMRReading.new(meter.mpan_mprn, yesterday, 'ORIG', nil, yesterday, Array.new(48, 0.25)) },
                missing_readings: []
              }
          }
        end

        it 'is inserted into the database' do
          allow(downloader).to receive(:readings).and_return(readings)

          expect {upserter.perform}.to change(AmrDataFeedImportLog, :count).by(1).and change(AmrDataFeedReading, :count).by(1)
        end
      end
    end
  end
end
