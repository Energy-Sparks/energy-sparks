# frozen_string_literal: true

require 'rails_helper'

describe 'solar:import_solis_cloud_readings' do # rubocop:disable RSpec/DescribeClass
  let(:installation) do
    create(:solis_cloud_installation, inverter_detail_list: JSON.parse(self.class::LIST_JSON)['data']['records'])
  end
  let!(:meter) do
    create(:solar_pv_meter, pseudo: true, solis_cloud_installation: installation,
                            meter_serial_number: '1805090224220126')
  end
  let(:task) do
    task = Rake::Task[self.class.description]
    task.reenable
    task
  end

  before { Rails.application.load_tasks unless Rake::Task.tasks.any? }

  def stub
    stub_request(:post, 'https://www.soliscloud.com:13333/v1/api/inverterDay')
  end

  def stub_inverter_day(serial, time, body)
    stub.to_return(body:, headers: { 'Content-Type' => 'application/json' })
        .with(body: { sn: serial, money: 'GBP', time: time.to_date.iso8601, timeZone: 0 }.to_json)
  end

  # rubocop:disable RSpec/LeakyConstantDeclaration -- don't think this is leaky because of self?
  self::LIST_JSON = File.read('spec/fixtures/solis_cloud/inverter_detail_list.json').freeze
  self::DAY_JSON = File.read('spec/fixtures/solis_cloud/inverter_day.json').freeze
  # rubocop:enable RSpec/LeakyConstantDeclaration

  it 'downloads and saves readings' do
    travel_to(Time.utc(2025, 1, 10))
    stub_inverter_day(meter.meter_serial_number, '2025-01-09', self.class::DAY_JSON)
    task.invoke('2025-01-09')
    expect(installation.meters.reload.count).to eq(1)
    expect(installation.meters.first.amr_data_feed_readings.map { |reading| reading.readings[24].to_f }).to \
      match_array(be_within(0.01).of(16.20))
    expect(installation.meters.pluck(:name)).to \
      contain_exactly('SolisCloud - INV 3 Bluebell / Northwood College (1C5015)')
  end

  it 'works with no specified start and end dates' do
    travel_to(Date.new(2024, 3, 21))
    stub_inverter_day(meter.meter_serial_number, 1.day.ago, self.class::DAY_JSON)
    task.invoke
    expect(installation.meters.reload.count).to eq(1)
    expect(installation.meters.first.amr_data_feed_readings.map { |reading| reading.readings[7].to_f }).to \
      match_array(be_within(0.01).of(0.03))
    expect(installation.meters.first.amr_data_feed_readings.map { |reading| reading.readings[24].to_f }).to \
      match_array(be_within(0.01).of(16.20))
  end

  it 'works with no inverter first generation time' do
    travel_to(Date.new(2025, 1, 10))
    index = installation.inverter_detail_list.index { |inverter| inverter['sn'] == meter.meter_serial_number }
    installation.inverter_detail_list[index].delete('fisGenerateTimeStr')
    installation.update!(inverter_detail_list: installation.inverter_detail_list)
    stub_inverter_day(meter.meter_serial_number, '2024-01-10', self.class::DAY_JSON)
    task.invoke(nil, '2024-01-10')
    expect(installation.meters.first.amr_data_feed_readings.map { |reading| reading.readings[7].to_f }).to \
      match_array(be_within(0.01).of(0.03))
  end

  it 'with existing readings, it reloads last five days' do
    travel_to(Date.new(2023, 11, 16))
    (Date.new(2023, 11, 10)..Date.new(2023, 11, 15)).each do |day|
      stub_inverter_day(meter.meter_serial_number, day, self.class::DAY_JSON)
    end
    create(:amr_data_feed_reading, meter:, reading_date: '2023-11-15')
    task.invoke
    expect(installation.meters.first.amr_data_feed_readings.count).to eq(7)
  end

  it 'handles an API error' do
    stub.to_return(status: 403)
    task.invoke
    expect(installation.amr_data_feed_config.amr_data_feed_import_logs.first.error_messages).not_to be_nil
  end

  it 'works with nil data' do
    stub_inverter_day(meter.meter_serial_number, '2025-01-09', { data: nil }.to_json)
    task.invoke('2025-01-09', '2025-01-09')
    expect(installation.amr_data_feed_config.amr_data_feed_import_logs).to \
      contain_exactly(have_attributes(error_messages: nil, records_imported: 0))
  end

  def readings
    expect(meter.amr_data_feed_readings.length).to eq(1)
    meter.amr_data_feed_readings.first.readings
  end

  it 'handles no data' do
    stub_inverter_day(meter.meter_serial_number, '2025-01-09', { data: [] }.to_json)
    task.invoke('2025-01-09', '2025-01-09')
    expect(readings).to eq(Array.new(48, nil))
  end

  it 'handles one data item' do
    stub_inverter_day(meter.meter_serial_number, '2025-01-09', { data: [{ timeStr: '00:02', eToday: 100 }] }.to_json)
    task.invoke('2025-01-09', '2025-01-09')
    expect(readings).to eq(Array.new(48, nil))
  end
end
