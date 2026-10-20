# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable-next Metrics/ModuleLength
module Solar
  describe SolarEdgeDownloadAndUpsert do
    let(:installation) { create(:solar_edge_installation, :unconsented) }

    let(:requested_start_date) { nil }
    let(:requested_end_date) { nil }

    subject(:upserter) do
      described_class.new(installation:, start_date: requested_start_date, end_date: requested_end_date)
    end

    context 'with a v1 SolarEdge site' do
      let(:readings) do
        {
          solar_pv: { readings: { 'Sun, 29 Nov 2020' => Array.new(48, 1.0),
                                  'Mon, 30 Nov 2020' => Array.new(48, 2.0) } },
          electricity: { readings: { 'Sun, 29 Nov 2020' => Array.new(48, 3.0),
                                     'Mon, 30 Nov 2020' => Array.new(48, 4.0) } },
          exported_solar_pv: { readings: { 'Sun, 29 Nov 2020' => Array.new(48, 5.0),
                                           'Mon, 30 Nov 2020' => Array.new(48, 6.0) } }
        }
      end

      let(:api) { instance_double(DataFeeds::SolarEdgeApi) }

      before do
        allow(DataFeeds::SolarEdgeApi).to receive(:new).with(installation.api_key).and_return(api)
      end

      it 'handles and log exceptions' do
        allow(api).to receive(:smart_meter_data).and_raise(StandardError)
        allow(EnergySparks::Log).to receive(:exception).and_return(nil)
        upserter.perform
        expect(AmrDataFeedImportLog.count).to be 1
        expect(AmrDataFeedImportLog.first.error_messages).not_to be_blank
      end

      context 'when a date window is given' do
        let(:requested_start_date) { requested_end_date - 1 }
        let(:requested_end_date) { Time.zone.today }

        before do
          allow(api).to receive(:smart_meter_data).with(installation.site_id, requested_start_date,
                                                        requested_end_date).and_return(readings)
        end

        it 'uses that' do
          upserter.perform
          expect(api).to have_received(:smart_meter_data).with(installation.site_id, requested_start_date,
                                                               requested_end_date)
        end

        it 'inserts data' do
          expect { upserter.perform }.to change(AmrDataFeedReading, :count).from(0).to(6)
        end
      end

      context 'when there are existing readings' do
        let(:meter) do
          create(:electricity_meter, school: installation.school,
                                     solar_edge_installation: installation)
        end

        before do
          create(:amr_data_feed_reading, reading_date: reading_date, parsed_date: reading_date, meter: meter)
          allow(api).to receive(:smart_meter_data).with(installation.site_id, expected_start,
                                                        expected_end).and_return(readings)
        end

        context 'and they are old' do
          let(:reading_date)  { Date.yesterday - 20 }
          let(:expected_start) { reading_date }
          let(:expected_end) { Date.yesterday }

          it 'uses last reading date as start' do
            upserter.perform
            expect(api).to have_received(:smart_meter_data).with(installation.site_id, expected_start,
                                                                 expected_end)
          end
        end

        context 'and they are recent' do
          let(:reading_date) { Date.yesterday }
          let(:expected_start) { Date.yesterday }
          let(:expected_end) { Date.yesterday }

          it 'defaults to loading only latest day' do
            upserter.perform
            expect(api).to have_received(:smart_meter_data).with(installation.site_id, expected_start,
                                                                 expected_end)
          end
        end

        context 'with reload flag set' do
          let(:upserter) do
            described_class.new(installation: installation, reload: true, start_date: nil, end_date: nil)
          end
          let(:reading_date) { Date.yesterday }

          let(:expected_start) { nil }
          let(:expected_end) { nil }

          it 'reloads all data' do
            upserter.perform
            expect(api).to have_received(:smart_meter_data).with(installation.site_id, expected_start,
                                                                 expected_end)
          end
        end
      end

      context 'when there are no readings' do
        let(:expected_end) { Date.yesterday }
        let(:expected_start) { nil }

        it 'loads all data' do
          allow(api).to receive(:smart_meter_data).with(installation.site_id, expected_start,
                                                        expected_end).and_return(readings)
          upserter.perform
          expect(api).to have_received(:smart_meter_data).with(installation.site_id, expected_start,
                                                               expected_end)
        end
      end
    end

    context 'with a v2 SolarEdge site' do
      let(:readings) do
        {
          Date.new(2020, 11, 29) => Array.new(48, 1.0),
          Date.new(2020, 11, 30) => Array.new(48, 2.0)
        }
      end

      let(:installation) { create(:solar_edge_installation) }
      let(:site_api) { instance_double(DataFeeds::SolarEdge::SiteApi) }

      def allow_solar_meter_api_methods(site_api:, start_date:, end_date:, serial_number:, readings:)
        allow(site_api).to receive(:production).with(start_date:,
                                                     end_date:).and_return(readings)

        allow(site_api).to receive(:import_energy).with(serial_number:,
                                                        start_date:,
                                                        end_date:).and_return(readings)

        allow(site_api).to receive(:export_energy).with(serial_number:,
                                                        start_date:,
                                                        end_date:).and_return(readings)
      end

      def expect_solar_meter_api_methods(site_api:, start_date:, end_date:, serial_number:)
        expect(site_api).to have_received(:production).with(start_date:,
                                                            end_date:)

        expect(site_api).to have_received(:import_energy).with(serial_number:,
                                                               start_date:,
                                                               end_date:)

        expect(site_api).to have_received(:export_energy).with(serial_number:,
                                                               start_date:,
                                                               end_date:)
      end

      before do
        allow(installation).to receive(:site_api!).and_return(site_api)
      end

      context 'when a date window is given' do
        let(:requested_start_date) { requested_end_date - 1 }
        let(:requested_end_date) { Time.zone.today }

        before do
          allow_solar_meter_api_methods(site_api:, start_date: requested_start_date,
                                        end_date: requested_end_date, serial_number: '12345', readings:)
        end

        it 'requests that date range for all meters' do
          expect { upserter.perform }.to change(AmrDataFeedReading, :count).from(0).to(6)
          expect_solar_meter_api_methods(site_api:, start_date: requested_start_date, end_date: requested_end_date,
                                         serial_number: '12345')
        end
      end

      context 'when there are existing readings for all meters' do
        before do
          create(:electricity_meter, :with_unvalidated_readings,
                 start_date: reading_date,
                 end_date: reading_date,
                 school: installation.school,
                 solar_edge_installation: installation)

          create(:exported_solar_pv_meter, :with_unvalidated_readings,
                 start_date: reading_date,
                 end_date: reading_date,
                 school: installation.school,
                 solar_edge_installation: installation)

          create(:solar_pv_meter, :with_unvalidated_readings,
                 start_date: reading_date,
                 end_date: reading_date,
                 school: installation.school,
                 solar_edge_installation: installation)

          allow_solar_meter_api_methods(site_api:, start_date: expected_start,
                                        end_date: expected_end, serial_number: '12345', readings:)
        end

        context 'and they are all lagging' do
          let(:reading_date)  { Date.yesterday - 20 }
          let(:expected_start) { reading_date }
          let(:expected_end) { Date.yesterday }

          it 'uses last reading date as start date to catch up' do
            upserter.perform
            expect_solar_meter_api_methods(site_api:, start_date: expected_start, end_date: expected_end,
                                           serial_number: '12345')
          end
        end

        context 'and they are recent' do
          let(:reading_date) { Date.yesterday }
          let(:expected_start) { Date.yesterday }
          let(:expected_end) { Date.yesterday }

          it 'defaults to loading only the latest day' do
            upserter.perform
            expect_solar_meter_api_methods(site_api:, start_date: expected_start, end_date: expected_end,
                                           serial_number: '12345')
          end
        end

        context 'with the reload flag set' do
          let(:upserter) do
            described_class.new(installation: installation, reload: true, start_date: nil, end_date: nil)
          end
          let(:reading_date) { Date.yesterday }

          let(:expected_start) { nil }
          let(:expected_end) { nil }

          it 'reloads all data' do
            upserter.perform
            expect_solar_meter_api_methods(site_api:, start_date: expected_start, end_date: expected_end,
                                           serial_number: '12345')
          end
        end
      end

      context 'when there are no readings' do
        let(:expected_end) { Date.yesterday }
        let(:expected_start) { nil }

        before do
          allow_solar_meter_api_methods(site_api:, start_date: expected_start,
                                        end_date: expected_end, serial_number: '12345', readings:)
        end

        it 'loads all historical data' do
          upserter.perform
          expect_solar_meter_api_methods(site_api:, start_date: expected_start, end_date: expected_end,
                                         serial_number: '12345')
        end
      end

      context 'when the import and export meters are inactive' do
        let(:reading_date) { Date.yesterday - 20 }
        let(:expected_start) { reading_date }
        let(:expected_end) { Date.yesterday }

        before do
          create(:electricity_meter,
                 active: false,
                 school: installation.school,
                 solar_edge_installation: installation)

          create(:exported_solar_pv_meter,
                 active: false,
                 school: installation.school,
                 solar_edge_installation: installation)

          create(:solar_pv_meter, :with_unvalidated_readings,
                 start_date: reading_date,
                 end_date: reading_date,
                 school: installation.school,
                 solar_edge_installation: installation)

          allow(site_api).to receive(:production).with(start_date: expected_start,
                                                       end_date: expected_end).and_return(readings)
        end

        it 'only loads the solar production data' do
          expect { upserter.perform }.to change(AmrDataFeedReading, :count).from(1).to(3)
          expect(site_api).to have_received(:production).with(start_date: expected_start, end_date: expected_end)
        end
      end

      context 'when the import and electricity SolarEdge meters are inactive' do
        let(:reading_date) { Date.yesterday - 20 }
        let(:expected_start) { reading_date }
        let(:expected_end) { Date.yesterday }

        let(:installation) { create(:solar_edge_installation, :with_inactive_import_and_export) }

        before do
          create(:electricity_meter,
                 school: installation.school,
                 solar_edge_installation: installation)

          create(:exported_solar_pv_meter,
                 school: installation.school,
                 solar_edge_installation: installation)

          create(:solar_pv_meter, :with_unvalidated_readings,
                 start_date: reading_date,
                 end_date: reading_date,
                 school: installation.school,
                 solar_edge_installation: installation)

          allow(site_api).to receive(:production).with(start_date: expected_start,
                                                       end_date: expected_end).and_return(readings)
        end

        it 'only loads the solar production data' do
          expect { upserter.perform }.to change(AmrDataFeedReading, :count).from(1).to(3)
          expect(site_api).to have_received(:production).with(start_date: expected_start, end_date: expected_end)
        end
      end

      context 'when the import and export meters are lagging' do
        it 'requests separate date ranges for each meter'
      end

      context 'when the monitoring is still in a pending status' do
        let(:installation) { create(:solar_edge_installation, :pending_status) }

        let(:requested_start_date) { requested_end_date - 1 }
        let(:requested_end_date) { Time.zone.today }

        context 'when status has changed' do
          before do
            allow(site_api).to receive_messages(details: {
                                                  'activationStatus' => 'ACTIVE'
                                                }, date_range: {
                                                  from: requested_start_date,
                                                  to: requested_end_date
                                                }, inventory: [
                                                  { 'type' => 'METER',
                                                    'active' => true,
                                                    'meterType' => 'FeedIn',
                                                    'name' => 'Export Meter',
                                                    'serialNumber' => '12345' },
                                                  { 'type' => 'METER',
                                                    'active' => true,
                                                    'meterType' => 'Purchased',
                                                    'name' => 'Import Meter',
                                                    'serialNumber' => '12345' }
                                                ])

            allow_solar_meter_api_methods(site_api:, start_date: requested_start_date,
                                          end_date: requested_end_date, serial_number: '12345', readings:)
          end

          it 'loads the data' do
            expect { upserter.perform }.to change(AmrDataFeedReading, :count).from(0).to(6)
            expect(site_api).to have_received(:details)
            expect(site_api).to have_received(:date_range)
            expect_solar_meter_api_methods(site_api:, start_date: requested_start_date, end_date: requested_end_date,
                                           serial_number: '12345')
          end
        end

        context 'when the status is still pending' do
          before do
            allow(site_api).to receive_messages(details: {
                                                  'activationStatus' => 'PENDING'
                                                }, inventory: [])
          end

          it 'does nothing' do
            expect { upserter.perform }.not_to change(AmrDataFeedReading, :count)
            expect(site_api).to have_received(:details)
          end
        end
      end
    end
  end
end
