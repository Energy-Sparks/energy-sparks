# frozen_string_literal: true

require 'rails_helper'

module Amr
  describe N3rgyReadingsDownloadAndUpsert do
    subject(:upserter) { described_class.new(config:, meter:) }

    let(:config) { create(:amr_data_feed_config, process_type: :n3rgy_api, source_type: :api) }
    let(:meter) { create(:electricity_meter) }

    let(:downloader) { instance_double(Amr::N3rgyDownloader) }

    let(:yesterday_first_reading) do
      (DateTime.now - 1).change(hour: 0, min: 30, sec: 0)
    end
    let(:yesterday_last_reading) do
      DateTime.now.change(hour: 0, min: 0, sec: 0)
    end
    let(:available_data) { [yesterday_first_reading, yesterday_last_reading] }

    before do
      # Use a fixed date for today to avoid any date/time issues
      travel_to Date.new(2024, 4, 20)
      metering_service_stub = instance_double(Meters::N3rgyMeteringService)
      allow(Meters::N3rgyMeteringService).to receive(:new).and_return(metering_service_stub)
      allow(metering_service_stub).to receive(:available_data).and_return(available_data)
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

      context 'when override start and end dates are provided' do
        let(:end_date)          { DateTime.now - 7 }
        let(:start_date)        { end_date - 8 }

        subject(:upserter) do
          described_class.new(config:, meter:, override_start_date: start_date, override_end_date: end_date)
        end
        it 'uses those dates' do
          expect(Amr::N3rgyDownloader).to receive(:new).with(
            meter:,
            start_date:,
            end_date:
          )
          allow(downloader).to receive(:readings).and_return({})
          upserter.perform
        end
      end

      context 'when there are no readings in database' do
        before do
          allow(downloader).to receive(:readings).and_return({})
        end

        context 'with available data in n3rgy' do
          let(:earliest) { DateTime.parse('2019-01-01T00:30') }

          let(:available_data) do
            [earliest, yesterday_last_reading]
          end

          it 'loads all the data' do
            expect(Amr::N3rgyDownloader).to receive(:new).with(
              meter:,
              start_date: earliest,
              end_date: yesterday_last_reading
            )
            expect(downloader).to receive(:readings)
            upserter.perform
          end

          context 'with available data start as a midnight' do
            let(:earliest) { DateTime.parse('2019-01-02T00:00') }

            it 'winds back a day' do
              expect(Amr::N3rgyDownloader).to receive(:new).with(
                meter:,
                start_date: DateTime.parse('2019-01-01T00:00'),
                end_date: yesterday_last_reading
              )
              expect(downloader).to receive(:readings)
              upserter.perform
            end
          end

          context 'with available date end in the future' do
            let(:available_data) do
              [earliest, (DateTime.now + 1)]
            end

            it 'only loads data up to yesterday' do
              expect(Amr::N3rgyDownloader).to receive(:new).with(
                meter:,
                start_date: earliest,
                end_date: yesterday_last_reading
              )
              expect(downloader).to receive(:readings)
              upserter.perform
            end
          end

          context 'with available data end after midnight' do
            let(:available_data) do
              [earliest, DateTime.now.change(hour: 10, min: 30, sec: 0)]
            end

            it 'only loads data up until previous day' do
              expect(Amr::N3rgyDownloader).to receive(:new).with(
                meter:,
                start_date: earliest,
                end_date: yesterday_last_reading
              )
              expect(downloader).to receive(:readings)
              upserter.perform
            end
          end

          context 'with dcc other meter' do
            it 'winds back a day' do
              meter.update!(dcc_meter: :other)
              expect(Amr::N3rgyDownloader).to \
                receive(:new).with(meter:, start_date: earliest, end_date: yesterday_last_reading - 1.day)
              upserter.perform
            end
          end
        end

        context 'with no available data in n3rgy' do
          let(:available_data) { [] }

          it 'does not attempt to load data' do
            expect(Amr::N3rgyDownloader).not_to receive(:new)
            expect(downloader).not_to receive(:readings)
            upserter.perform
          end
        end
      end

      context 'when there are previously loaded readings' do
        # NOTE: this is a Date object as the reading date needs to be stored in the database
        # in ISO 8601 format e.g. 2023-06-29
        let(:earliest_reading) { Date.new(2024, 4, 1) }
        let(:days_of_data) { 10 }

        before do
          days_of_data.times do |n|
            create(:amr_data_feed_reading, amr_data_feed_config: config, meter:, reading_date: earliest_reading + n)
          end
          allow(downloader).to receive(:readings).and_return({})
        end

        context 'with earlier data available from n3rgy' do
          let(:expected_start) { DateTime.parse('2024-03-31T00:30') }
          let(:available_data) { [expected_start, yesterday_last_reading] }

          it 'requests earlier data from n3rgy if they have data prior to the first reading' do
            expect(Amr::N3rgyDownloader).to receive(:new).with(
              meter:,
              start_date: expected_start,
              end_date: yesterday_last_reading
            )
            upserter.perform
          end
        end

        context 'with earlier data in our database' do
          let(:expected_start) { DateTime.parse('2024-04-2T00:30') }
          let(:available_data) { [expected_start, yesterday_last_reading] }

          context 'when there is >7 days available' do
            it 'justs reload the last 7 days from n3rgy' do
              expect(Amr::N3rgyDownloader).to receive(:new).with(
                meter:,
                start_date: earliest_reading + 2, # reload last week
                end_date: yesterday_last_reading
              )
              upserter.perform
            end
          end

          context 'when there is <7 days of data available' do
            let(:days_of_data) { 3 }

            it 'reloads all the data' do
              expect(Amr::N3rgyDownloader).to receive(:new).with(
                meter:,
                start_date: expected_start,
                end_date: yesterday_last_reading
              )
              upserter.perform
            end
          end

          context 'when reload option is set' do
            subject(:upserter) do
              described_class.new(config:, meter:, reload: true)
            end

            it 'reloads all the data' do
              expect(Amr::N3rgyDownloader).to receive(:new).with(
                meter:,
                start_date: expected_start,
                end_date: yesterday_last_reading
              )
              upserter.perform
            end
          end
        end

        context 'when we are up to date' do
          let(:available_data) do
            [DateTime.parse('2024-04-01T00:30'), DateTime.parse('2024-04-10T00:00')]
          end

          it 'still reloads the last week every time' do
            expect(Amr::N3rgyDownloader).to receive(:new).with(
              meter:,
              start_date: available_data.first + 2,
              end_date: available_data.last
            )
            upserter.perform
          end

          context 'when reload option is set' do
            subject(:upserter) do
              described_class.new(config:, meter:, reload: true)
            end

            it 'reloads all the data' do
              expect(Amr::N3rgyDownloader).to receive(:new).with(
                meter:,
                start_date: available_data.first,
                end_date: available_data.last
              )
              upserter.perform
            end
          end
        end

        context 'with no data from n3rgy' do
          let(:available_data) { [] }

          it 'does not attempt to load data' do
            expect(Amr::N3rgyDownloader).not_to receive(:new)
            expect(downloader).not_to receive(:readings)
            upserter.perform
          end
        end
      end

      context 'when some reading data is returned' do
        let(:readings) do
          yesterday = Time.zone.today - 1
          {
            meter.meter_type => {
              mpan_mprn: meter.mpan_mprn,
              readings: { yesterday => OneDayAMRReading.new(meter.mpan_mprn, yesterday, 'ORIG', nil,
                                                            yesterday, Array.new(48, 0.25)) },
              missing_readings: []
            }
          }
        end

        it 'is inserted into the database' do
          allow(downloader).to receive(:readings).and_return(readings)

          expect do
            upserter.perform
          end.to change(AmrDataFeedImportLog, :count).by(1).and change(AmrDataFeedReading, :count).by(1)
        end
      end
    end
  end
end
