require 'rails_helper'

module Amr
  describe N3rgyReadingsDownloadAndUpsert do
    let(:earliest) { DateTime.parse('2019-01-01T00:00') }
    let(:thirteen_months_ago) { DateTime.now - 13.months }
    let(:meter)             { create(:electricity_meter, earliest_available_data: earliest) }
    let(:config)            { create(:amr_data_feed_config)}
    let(:end_date)          { DateTime.now - 7 }
    let(:start_date)        { end_date - 8 }
    let(:yesterday) { DateTime.now - 1 }

    let(:readings) do
      {
        meter.meter_type => {
            mpan_mprn:        meter.mpan_mprn,
            readings:         { start_date => OneDayAMRReading.new(meter.mpan_mprn, start_date, 'ORIG', nil, start_date, Array.new(48, 0.25)) },
            missing_readings: []
          }
      }
    end

    around do |example|
      ClimateControl.modify FEATURE_FLAG_N3RGY_V2: flag do
        example.run
      end
    end

    context 'with v1' do
      let(:flag) { 'false' }

      let(:n3rgy_api)         { double(:n3rgy_api) }
      let(:n3rgy_api_factory) { double(:n3rgy_api_factory, data_api: n3rgy_api) }

      context 'when downloading data' do
        it 'handles and log exceptions' do
          expect(AmrDataFeedImportLog.count).to be 0
          expect(n3rgy_api).to receive(:readings).and_raise(StandardError)
          upserter = Amr::N3rgyReadingsDownloadAndUpsert.new(n3rgy_api_factory: n3rgy_api_factory, config: config, meter: meter, start_date: start_date, end_date: end_date)
          upserter.perform
          expect(AmrDataFeedImportLog.count).to be 1
          expect(AmrDataFeedImportLog.first.error_messages).not_to be_blank
        end

        it 'uses provided date window' do
          expect(n3rgy_api).to receive(:readings).with(meter.mpan_mprn, meter.meter_type, start_date, end_date).and_return(readings)
          upserter = Amr::N3rgyReadingsDownloadAndUpsert.new(n3rgy_api_factory: n3rgy_api_factory, config: config, meter: meter, start_date: start_date, end_date: end_date)
          upserter.perform
        end

        it 'uses earliest available data if no date window' do
          available_range = (earliest..yesterday)
          expect(n3rgy_api).to receive(:readings_available_date_range).with(meter.mpan_mprn, meter.fuel_type).and_return(available_range)
          expect(n3rgy_api).to receive(:readings).with(meter.mpan_mprn, meter.meter_type, earliest, yesterday).and_return(readings)
          upserter = Amr::N3rgyReadingsDownloadAndUpsert.new(n3rgy_api_factory: n3rgy_api_factory, config: config, meter: meter, start_date: nil, end_date: nil)
          upserter.perform
        end

        it 'requests 12 months if no earliest data is unknown and no readings' do
          expect(n3rgy_api).to receive(:readings_available_date_range).with(meter.mpan_mprn, meter.fuel_type).and_return(nil)
          expect(n3rgy_api).to receive(:readings).with(meter.mpan_mprn, meter.meter_type, thirteen_months_ago, yesterday).and_return(readings)

          meter.update!({
            earliest_available_data: nil
          })

          upserter = Amr::N3rgyReadingsDownloadAndUpsert.new(n3rgy_api_factory: n3rgy_api_factory, config: config, meter: meter, start_date: nil, end_date: nil)
          upserter.perform
        end

        context 'when there are readings' do
          # Note: this is a Date object as the reading date needs to be stored in the database in ISO 8601 format e.g. 2023-06-29
          let(:last_week) { Time.zone.today - 7 }

          before do
            create(:amr_data_feed_reading, meter: meter, reading_date: last_week)
            create(:amr_data_feed_reading, meter: meter, reading_date: last_week + 1)
            create(:amr_data_feed_reading, meter: meter, reading_date: last_week + 2)
          end

          it 'requests data from first available date if that was earlier than current first reading' do
            available_range = (last_week - 1..yesterday)
            expect(n3rgy_api).to receive(:readings_available_date_range).with(meter.mpan_mprn, meter.fuel_type).and_return(available_range)
            expect(n3rgy_api).to receive(:readings).with(meter.mpan_mprn, meter.meter_type, last_week - 1, yesterday).and_return(readings)

            # maximum and minimum amr data feed readings reading date should be in ISO 8601 format e.g. '2023-06-29'
            expect(meter.amr_data_feed_readings.minimum(:reading_date)).to match(/^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[1-2][0-9]|3[0-1])$/)
            expect(meter.amr_data_feed_readings.maximum(:reading_date)).to match(/^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[1-2][0-9]|3[0-1])$/)

            upserter = Amr::N3rgyReadingsDownloadAndUpsert.new(n3rgy_api_factory: n3rgy_api_factory, config: config, meter: meter, start_date: nil, end_date: nil)
            upserter.perform
          end

          it 'requests data from current last reading if first available date is equal to current first reading' do
            available_range = (last_week..yesterday)
            expect(n3rgy_api).to receive(:readings_available_date_range).with(meter.mpan_mprn, meter.fuel_type).and_return(available_range)
            expect(n3rgy_api).to receive(:readings).with(meter.mpan_mprn, meter.meter_type, last_week + 2, yesterday).and_return(readings)

            upserter = Amr::N3rgyReadingsDownloadAndUpsert.new(n3rgy_api_factory: n3rgy_api_factory, config: config, meter: meter, start_date: nil, end_date: nil)
            upserter.perform
          end

          it 'requests data from 13 months ago if no available date range' do
            expect(n3rgy_api).to receive(:readings_available_date_range).with(meter.mpan_mprn, meter.fuel_type).and_return(nil)
            expect(n3rgy_api).to receive(:readings).with(meter.mpan_mprn, meter.meter_type, thirteen_months_ago, yesterday).and_return(readings)

            upserter = Amr::N3rgyReadingsDownloadAndUpsert.new(n3rgy_api_factory: n3rgy_api_factory, config: config, meter: meter, start_date: nil, end_date: nil)
            upserter.perform
          end
        end
      end

      context 'when upserting data' do
        it 'results in new readings' do
          expect(n3rgy_api).to receive(:readings).with(meter.mpan_mprn, meter.meter_type, start_date, end_date).and_return(readings)
          upserter = Amr::N3rgyReadingsDownloadAndUpsert.new(n3rgy_api_factory: n3rgy_api_factory, config: config, meter: meter, start_date: start_date, end_date: end_date)
          upserter.perform

          expect(AmrDataFeedImportLog.count).to be 1
          expect(AmrDataFeedReading.count).to be 1
        end
      end
    end

    context 'with v2' do
      let(:flag) { 'true' }

      let(:downloader) { instance_double(Amr::N3rgyDownloader) }
      let(:n3rgy_api_factory) { nil }

      describe '#perform' do
        context 'with an error downloading data' do
          it 'handles and log exceptions' do
            expect(AmrDataFeedImportLog.count).to be 0
            allow(Amr::N3rgyDownloader).to receive(:new).and_return(downloader)
            expect(downloader).to receive(:readings).and_raise(StandardError)

            upserter = Amr::N3rgyReadingsDownloadAndUpsert.new(n3rgy_api_factory: n3rgy_api_factory, config: config, meter: meter, start_date: start_date, end_date: end_date)
            upserter.perform

            expect(AmrDataFeedImportLog.count).to be 1
            expect(AmrDataFeedImportLog.first.error_messages).not_to be_blank
          end
        end

        context 'when downloading data' do
          let(:readings) { {} }

          it 'uses start and end dates if provided' do
            expect(Amr::N3rgyDownloader).to receive(:new).with(
              meter: meter,
              start_date: start_date,
              end_date: end_date,
              n3rgy_api: anything
            ).and_return(downloader)
            expect(downloader).to receive(:readings).and_return(readings)

            upserter = Amr::N3rgyReadingsDownloadAndUpsert.new(n3rgy_api_factory: n3rgy_api_factory, config: config, meter: meter, start_date: start_date, end_date: end_date)
            upserter.perform
          end

          it 'loads all available data if no dates specified' do
            available_range = (earliest..yesterday)

            metering_service_stub = double('metering-service')
            expect(Meters::N3rgyMeteringService).to receive(:new).and_return(metering_service_stub)
            expect(metering_service_stub).to receive(:available_data).and_return(available_range)

            expect(Amr::N3rgyDownloader).to receive(:new).with(
              meter: meter,
              start_date: earliest,
              end_date: yesterday,
              n3rgy_api: anything
            ).and_return(downloader)
            expect(downloader).to receive(:readings).and_return(readings)

            upserter = Amr::N3rgyReadingsDownloadAndUpsert.new(n3rgy_api_factory: n3rgy_api_factory, config: config, meter: meter, start_date: nil, end_date: nil)
            upserter.perform
          end

          it 'requests 12 months by default if no other dates available' do
            metering_service_stub = double('metering-service')
            expect(Meters::N3rgyMeteringService).to receive(:new).and_return(metering_service_stub)
            expect(metering_service_stub).to receive(:available_data).and_return(nil)

            expect(Amr::N3rgyDownloader).to receive(:new).with(
              meter: meter,
              start_date: thirteen_months_ago,
              end_date: yesterday,
              n3rgy_api: anything
            ).and_return(downloader)
            expect(downloader).to receive(:readings).and_return(readings)

            meter.update!({
              earliest_available_data: nil
            })

            upserter = Amr::N3rgyReadingsDownloadAndUpsert.new(n3rgy_api_factory: n3rgy_api_factory, config: config, meter: meter, start_date: nil, end_date: nil)
            upserter.perform
          end

          context 'when some readings have already been loaded' do
            # Note: this is a Date object as the reading date needs to be stored in the database in ISO 8601 format e.g. 2023-06-29
            let(:last_week) { Time.zone.today - 7 }

            before do
              create(:amr_data_feed_reading, meter: meter, reading_date: last_week)
              create(:amr_data_feed_reading, meter: meter, reading_date: last_week + 1)
              create(:amr_data_feed_reading, meter: meter, reading_date: last_week + 2)
            end

            it 'requests earlier data from n3rgy if they have data prior to the first reading' do
              available_range = (last_week - 1..yesterday)

              metering_service_stub = double('metering-service')
              expect(Meters::N3rgyMeteringService).to receive(:new).and_return(metering_service_stub)
              expect(metering_service_stub).to receive(:available_data).and_return(available_range)

              expect(Amr::N3rgyDownloader).to receive(:new).with(
                meter: meter,
                start_date: last_week - 1,
                end_date: yesterday,
                n3rgy_api: anything
              ).and_return(downloader)
              expect(downloader).to receive(:readings).and_return(readings)

              # maximum and minimum amr data feed readings reading date should be in ISO 8601 format e.g. '2023-06-29'
              expect(meter.amr_data_feed_readings.minimum(:reading_date)).to match(/^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[1-2][0-9]|3[0-1])$/)
              expect(meter.amr_data_feed_readings.maximum(:reading_date)).to match(/^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[1-2][0-9]|3[0-1])$/)

              upserter = Amr::N3rgyReadingsDownloadAndUpsert.new(n3rgy_api_factory: n3rgy_api_factory, config: config, meter: meter, start_date: nil, end_date: nil)
              upserter.perform
            end

            it 'requests newer data if we have the earliest readings' do
              available_range = (last_week..yesterday)

              metering_service_stub = double('metering-service')
              expect(Meters::N3rgyMeteringService).to receive(:new).and_return(metering_service_stub)
              expect(metering_service_stub).to receive(:available_data).and_return(available_range)

              expect(Amr::N3rgyDownloader).to receive(:new).with(
                meter: meter,
                start_date: last_week + 2,
                end_date: yesterday,
                n3rgy_api: anything
              ).and_return(downloader)
              expect(downloader).to receive(:readings).and_return(readings)

              upserter = Amr::N3rgyReadingsDownloadAndUpsert.new(n3rgy_api_factory: n3rgy_api_factory, config: config, meter: meter, start_date: nil, end_date: nil)
              upserter.perform
            end

            it 'requests data from 13 months ago if no date ranges available from n3rgy' do
              metering_service_stub = double('metering-service')
              expect(Meters::N3rgyMeteringService).to receive(:new).and_return(metering_service_stub)
              expect(metering_service_stub).to receive(:available_data).and_return(nil)

              expect(Amr::N3rgyDownloader).to receive(:new).with(
                meter: meter,
                start_date: thirteen_months_ago,
                end_date: yesterday,
                n3rgy_api: anything
              ).and_return(downloader)
              expect(downloader).to receive(:readings).and_return(readings)

              upserter = Amr::N3rgyReadingsDownloadAndUpsert.new(n3rgy_api_factory: n3rgy_api_factory, config: config, meter: meter, start_date: nil, end_date: nil)
              upserter.perform
            end
          end
        end

        context 'when data is returned' do
          it 'is inserted into the database' do
            expect(Amr::N3rgyDownloader).to receive(:new).with(
              meter: meter,
              start_date: start_date,
              end_date: end_date,
              n3rgy_api: anything
            ).and_return(downloader)
            expect(downloader).to receive(:readings).and_return(readings)

            upserter = Amr::N3rgyReadingsDownloadAndUpsert.new(n3rgy_api_factory: n3rgy_api_factory, config: config, meter: meter, start_date: start_date, end_date: end_date)
            upserter.perform

            expect(AmrDataFeedImportLog.count).to be 1
            expect(AmrDataFeedReading.count).to be 1
          end
        end
      end
    end
  end
end
