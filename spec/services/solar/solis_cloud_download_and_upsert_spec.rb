# frozen_string_literal: true

require 'rails_helper'

describe Solar::SolisCloudDownloadAndUpsert do
  let(:installation) { create(:solis_cloud_installation) }

  def stub(action, body)
    headers = { 'Content-Type' => 'application/json' }
    stub_request(:post, "https://www.soliscloud.com:13333/v1/api/#{action}").to_return(body:, headers:)
  end

  def stub_station_day(id, time, body)
    stub('stationDay', body).with(body: { id:, money: 'GBP', time:, timeZone: 44 }.to_json)
  end

  self::LIST_JSON = File.read('spec/fixtures/solis_cloud/user_station_list.json') # rubocop:disable RSpec/LeakyConstantDeclaration
  self::DAY_JSON = File.read('spec/fixtures/solis_cloud/station_day.json') # rubocop:disable RSpec/LeakyConstantDeclaration

  def stub_stations_day(time)
    stub('userStationList', self.class::LIST_JSON)
    stub_station_day('1298491919449314564', time, self.class::DAY_JSON)
    stub_station_day('1298491919449314551', time, self.class::DAY_JSON)
  end

  it 'downloads and saves readings' do
    stub_stations_day('2025-01-09')
    described_class.new(start_date: Date.new(2025, 1, 9), end_date: Date.new(2025, 1, 9),
                        installation:).download_and_upsert
    expect(installation.meters.pluck(:mpan_mprn)).to contain_exactly(70_000_001_799_272, 70_000_001_799_259)
    expect(installation.meters.first.amr_data_feed_readings.map { |reading| reading.readings[20] }).to \
      eq(['1.9033333333333333'])
    expect(installation.meters.pluck(:meter_serial_number)).to contain_exactly('1298491919449314564',
                                                                               '1298491919449314551')
    expect(installation.meters.pluck(:name)).to contain_exactly('SolisCloud Inverter 1', 'SolisCloud Inverter 2')
    expect(installation.station_list.length).to eq(2)
  end

  it 'works with no specified start and end dates' do
    travel_to(Date.new(2023, 11, 16))
    stub_stations_day('2023-11-15')
    described_class.new(start_date: nil, end_date: nil, installation:).download_and_upsert
    expect(installation.meters.first.amr_data_feed_readings.count).to eq(1)
  end

  it 'works with nil data' do
    stub('userStationList', { data: { page: { records: [{ id: 1, sno: '1' }] } } }.to_json)
    stub_station_day(1, '2025-01-09', { data: nil }.to_json)
    upserter = described_class.new(start_date: Date.new(2025, 1, 9), end_date: Date.new(2025, 1, 9), installation:)
    upserter.download_and_upsert
    expect(upserter.import_log.records_imported).to eq(0)
  end

  it 'with existing readings, it reloads last five days' do
    travel_to(Date.new(2023, 11, 16))
    (Date.new(2023, 11, 10)..Date.new(2023, 11, 15)).each do |day|
      stub_stations_day(day.iso8601)
    end
    create(:solar_pv_meter,
           :with_unvalidated_readings,
           mpan_mprn: 70_000_001_799_272,
           pseudo: true,
           end_date: Date.parse('2023-11-15'),
           meter_serial_number: '1298491919449314564',
           solis_cloud_installation: installation,
           school: installation.school)
    described_class.new(start_date: nil, end_date: nil, installation:).download_and_upsert
    expect(installation.meters.first.amr_data_feed_readings.count).to eq(7)
  end
end
