# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable-next Metrics/ModuleLength
module Solar
  describe SolarEdgeDownloadAndUpsert do
    let(:installation) { create(:solar_edge_installation, :unconsented, mpan: 1_112_223_334_445) }

    let(:readings) do
      {
        solar_pv: { readings: { 'Sun, 29 Nov 2020' => Array.new(48, 1.0), 'Mon, 30 Nov 2020' => Array.new(48, 2.0) } },
        electricity: { readings: { 'Sun, 29 Nov 2020' => Array.new(48, 3.0),
                                   'Mon, 30 Nov 2020' => Array.new(48, 4.0) } },
        exported_solar_pv: { readings: { 'Sun, 29 Nov 2020' => Array.new(48, 5.0),
                                         'Mon, 30 Nov 2020' => Array.new(48, 6.0) } }
      }
    end

    let(:requested_start_date) { nil }
    let(:requested_end_date) { nil }

    subject(:upserter) do
      described_class.new(installation:, start_date: requested_start_date, end_date: requested_end_date)
    end

    context 'with a v1 SolarEdge site' do
      # rubocop:disable-next RSpec/VerifiedDoubles
      let(:api) { double('solar-edge-api') }

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
          create(:electricity_meter, mpan_mprn: "9#{installation.mpan}".to_i, school: installation.school,
                                     solar_edge_installation: installation)
        end

        before do
          create(:amr_data_feed_reading, reading_date: reading_date, meter: meter)
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
      let(:installation) { create(:solar_edge_installation, mpan: 1_112_223_334_445) }

      let(:site_api) { instance_double(DataFeeds::SolarEdge::SiteApi) }

      before do
        allow(installation).to receive(:site_api!).and_return(site_api)
      end

      context 'when a date window is given' do
        let(:requested_start_date) { requested_end_date - 1 }
        let(:requested_end_date) { Time.zone.today }

        before do
          allow(site_api).to receive(:all_meter_data).with(start_date: requested_start_date,
                                                           end_date: requested_end_date).and_return(readings)
        end

        it 'inserts data' do
          expect { upserter.perform }.to change(AmrDataFeedReading, :count).from(0).to(6)
          expect(site_api).to have_received(:all_meter_data).with(start_date: requested_start_date,
                                                                  end_date: requested_end_date)
        end
      end

      context 'when there are existing readings' do
        let(:meter) do
          create(:electricity_meter, mpan_mprn: "9#{installation.mpan}".to_i, school: installation.school,
                                     solar_edge_installation: installation)
        end

        before do
          create(:amr_data_feed_reading, reading_date: reading_date, meter: meter)
          allow(site_api).to receive(:all_meter_data).with(start_date: expected_start,
                                                           end_date: expected_end).and_return(readings)
        end

        context 'and they are old' do
          let(:reading_date)  { Date.yesterday - 20 }
          let(:expected_start) { reading_date }
          let(:expected_end) { Date.yesterday }

          it 'uses last reading date as start' do
            upserter.perform
            expect(site_api).to have_received(:all_meter_data).with(start_date: expected_start,
                                                                    end_date: expected_end)
          end
        end

        context 'and they are recent' do
          let(:reading_date) { Date.yesterday }
          let(:expected_start) { Date.yesterday }
          let(:expected_end) { Date.yesterday }

          it 'defaults to loading only latest day' do
            upserter.perform
            expect(site_api).to have_received(:all_meter_data).with(start_date: expected_start,
                                                                    end_date: expected_end)
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
            expect(site_api).to have_received(:all_meter_data).with(start_date: expected_start,
                                                                    end_date: expected_end)
          end
        end
      end

      context 'when there are no readings' do
        let(:expected_end) { Date.yesterday }
        let(:expected_start) { nil }

        before do
          allow(site_api).to receive(:all_meter_data).with(start_date: expected_start,
                                                           end_date: expected_end).and_return(readings)
        end

        it 'loads all data' do
          upserter.perform
          expect(site_api).to have_received(:all_meter_data).with(start_date: expected_start,
                                                                  end_date: expected_end)
        end
      end
    end
  end
end
