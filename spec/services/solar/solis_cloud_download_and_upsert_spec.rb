# frozen_string_literal: true

require 'rails_helper'

describe Solar::SolisCloudDownloadAndUpsert do
  it 'downloads and saves readings' do
    installation = SolisCloudInstallation.create(school: create(:school),
                                                 amr_data_feed_config: create(:amr_data_feed_config),
                                                 api_secret: 'secret')

    stub_request(:post, 'https://www.soliscloud.com:13333/v1/api/userStationList')
      .to_return(body: File.read('spec/fixtures/solis_cloud/user_station_list.json'),
                 headers: { 'Content-Type' => 'application/json' })
    stub_request(:post, 'https://www.soliscloud.com:13333/v1/api/stationDay')
      .with(body: { id: '1298491919449314564', money: 'GBP', time: '2025-01-09', timeZone: 44 }.to_json)
      .to_return(body: File.read('spec/fixtures/solis_cloud/station_day.json'),
                 headers: { 'Content-Type' => 'application/json' })
    stub_request(:post, 'https://www.soliscloud.com:13333/v1/api/stationDay')
      .with(body: { id: '1298491919449314551', money: 'GBP', time: '2025-01-09', timeZone: 44 }.to_json)
      .to_return(body: File.read('spec/fixtures/solis_cloud/station_day.json'),
                 headers: { 'Content-Type' => 'application/json' })

    described_class.new(start_date: Date.new(2025, 1, 9), end_date: Date.new(2025, 1, 9),
                        installation:).download_and_upsert
    expect(installation.meters.pluck(:mpan_mprn)).to contain_exactly(70_000_001_799_272, 70_000_001_799_259)
    expect(installation.meters.first.amr_data_feed_readings.map { |reading| reading.readings[20] }).to \
      eq(['1.9033333333333333'])
    expect(installation.meters.pluck(:meter_serial_number)).to contain_exactly('1298491919449314564',
                                                                               '1298491919449314551')
    expect(installation.station_list.length).to eq(2)
  end
end
