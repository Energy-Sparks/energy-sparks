# frozen_string_literal: true

require 'rails_helper'

describe Solar::SolisCloudDownloadAndUpsert do
  let(:installation) do
    create(:solis_cloud_installation, inverter_detail_list: JSON.parse(self.class::LIST_JSON)['data']['records'])
  end
  let!(:meter) do
    create(:solar_pv_meter, pseudo: true, solis_cloud_installation: installation,
                            meter_serial_number: '1805090224220126')
  end

  def stub(action, body)
    headers = { 'Content-Type' => 'application/json' }
    stub_request(:post, "https://www.soliscloud.com:13333/v1/api/#{action}").to_return(body:, headers:)
  end

  def stub_station_day(serial, time, body)
    stub('inverterDay', body).with(body: { sn: serial, money: 'GBP', time: time.to_date.iso8601, timeZone: 0 }.to_json)
  end

  self::LIST_JSON = File.read('spec/fixtures/solis_cloud/inverter_detail_list.json').freeze # rubocop:disable RSpec/LeakyConstantDeclaration
  self::DAY_JSON = File.read('spec/fixtures/solis_cloud/inverter_day.json').freeze # rubocop:disable RSpec/LeakyConstantDeclaration

  def stub_stations_day(time)
    # stub('userStationList', self.class::LIST_JSON)
    stub_station_day('1805090224220126', time, self.class::DAY_JSON)
    # stub_station_day('1298491919449314551', time, self.class::DAY_JSON)
  end

  it 'downloads and saves readings' do
    stub_stations_day('2025-01-09')
    described_class.new(start_date: Date.new(2025, 1, 9), end_date: Date.new(2025, 1, 9), installation:)
                   .download_and_upsert
    expect(installation.meters.reload.count).to eq(1)
    expect(installation.meters.first.amr_data_feed_readings.map { |reading| reading.readings[24] }).to eq(['8.5'])
    expect(installation.meters.pluck(:name)).to \
      contain_exactly('SolisCloud - INV 3 Bluebell / Northwood College (1C5015)')
  end

  it 'works with no specified start and end dates' do
    travel_to(Date.new(2024, 3, 21))
    stub_stations_day(1.day.ago)
    described_class.new(start_date: nil, end_date: nil, installation:).download_and_upsert
    expect(installation.meters.reload.count).to eq(1)
    expect(installation.meters.first.amr_data_feed_readings.map { |reading| reading.readings[7] }).to eq(['0'])
    expect(installation.meters.first.amr_data_feed_readings.map { |reading| reading.readings[24] }).to eq(['8.5'])
  end

  it 'works with nil data' do
    stub_station_day(meter.meter_serial_number, '2025-01-09', { data: nil }.to_json)
    upserter = described_class.new(start_date: Date.new(2025, 1, 9), end_date: Date.new(2025, 1, 9), installation:)
    upserter.download_and_upsert
    expect(upserter.import_log.records_imported).to eq(0)
  end

  it 'with existing readings, it reloads last five days' do
    travel_to(Date.new(2023, 11, 16))
    (Date.new(2023, 11, 10)..Date.new(2023, 11, 15)).each { |day| stub_stations_day(day.iso8601) }
    create(:amr_data_feed_reading, meter:, reading_date: '2023-11-15')
    described_class.new(start_date: nil, end_date: nil, installation:).download_and_upsert
    expect(installation.meters.first.amr_data_feed_readings.count).to eq(7)
  end
end
