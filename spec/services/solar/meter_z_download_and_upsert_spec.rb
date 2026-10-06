# frozen_string_literal: true

require 'rails_helper'

describe Solar::MeterZDownloadAndUpsert do
  subject(:download_and_upsert) { described_class.new(installation:) }

  let(:installation) { create(:meter_z_installation) }
  let!(:meter) { create(:solar_pv_meter, meter_z_installation: installation, meter_serial_number: '123') }

  def every_half_hour(count)
    time = DateTime.new(2025)
    [time] + Array.new(count).map { time += 30.minutes }
  end

  describe '#perform' do
    before do
      travel_to(Date.new(2026))
      readings = every_half_hour(48 * 5).map.with_index do |time, i|
        { 'reading_timestamp' => time.iso8601, 'readings' => { 'accumulated_kilowatt_hours' => i.to_s } }
      end
      stub_request(:get, 'https://api.meterz.co.uk/v1/organisations/organisation_id/sites/site_id/meters/123' \
                         '/readings?start_datetime=2026-01-02&items_per_page=1000')
        .to_return(body: { readings: readings.reverse }.to_json, headers: { 'content-type' => 'application/json' })
    end

    it 'creates the correct readings' do
      download_and_upsert.perform
      expect(meter.amr_data_feed_readings.map(&:readings)).to eq([['1.0'] * 48] * 5)
    end
  end

  context 'when meterz errors' do
    before do
      travel_to(Date.new(2026))
      stub_request(:get, 'https://api.meterz.co.uk/v1/organisations/organisation_id/sites/site_id/meters/123' \
                         '/readings?start_datetime=2026-01-02&items_per_page=1000')
        .to_return(status: 404)
      allow(Rollbar).to receive(:error)
      download_and_upsert.perform
    end

    it 'creates the correct readings' do
      expect(Rollbar).to have_received(:error)
      installation.amr_data_feed_config.amr_data_feed_import_logs
      expect(installation.amr_data_feed_config.amr_data_feed_import_logs.first.error_messages).to \
        eq('Exception: downloading solar data from nil to 2025-12-31: school school-aaaaa1 meter_serial_number 123 ' \
           'start_date ')
    end
  end
end
