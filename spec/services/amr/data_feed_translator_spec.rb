# frozen_string_literal: true

require 'rails_helper'

describe Amr::DataFeedTranslator do
  let(:reading_fields) { (1..48).map { |i| "kWh_#{i}" } }
  let(:sheffield_config) do
    build(:amr_data_feed_config,
          description: 'Sheffield',
          date_format: '%d/%m/%Y',
          mpan_mprn_field: 'MPAN',
          units_field: 'units',
          reading_date_field: 'ConsumptionDate',
          period_field: 'Period',
          reading_fields: reading_fields,
          meter_description_field: 'siteRef',
          header_example:
            "siteRef,MPAN,ConsumptionDate,Period,units,#{reading_fields.join(',')},#{(1..48).map { |i| "kVArh_#{i}" }}")
  end
  let(:reading) do
    ['MEERSBROOK PRIMARY - M1', '2333300681718', '31/12/2019', '1', 'kwh',
     '1.20800000', '1.16100000', '1.19500000', '1.21000000', '1.16600000', '1.20100000',
     '1.17800000', '1.30000000', '1.30100000', '1.26600000', '1.27300000', '1.28000000',
     '2.10900000', '2.03700000', '1.29100000', '1.24600000', '1.67800000', '1.24500000',
     '1.12800000', '1.11300000', '1.35000000', '1.11700000', '1.14200000', '1.40600000',
     '1.10100000', '1.12300000', '1.16400000', '1.42700000', '1.12900000', '1.10400000',
     '1.11900000', '1.46600000', '1.18400000', '1.14600000', '1.22600000', '1.20800000',
     '1.25500000', '1.20000000', '1.23600000', '1.16300000', '1.12400000', '1.19800000',
     '1.12800000', '1.15500000', '1.13000000', '1.18200000', '1.14500000', '1.17700000'] + ([''] * 48)
  end

  it 'converts array rows to a keyed hash' do
    result = described_class.new(sheffield_config, [reading]).perform.first

    expect(result[:mpan_mprn]).to eq('2333300681718')
    expect(result[:reading_date]).to eq('31/12/2019')
    expect(result[:description]).to eq('MEERSBROOK PRIMARY - M1')
    expect(result[:readings].first).to eq('1.20800000')
    expect(result[:readings].last).to eq('1.17700000')
    expect(result[:units]).to eq('kwh')
  end

  it 'adds period for positionally indexed files' do
    sheffield_config.positional_index = true
    result = described_class.new(sheffield_config, [reading]).perform.first
    expect(result[:period]).to eq('1')
  end

  it 'removes rows that do not match the expected_units' do
    sheffield_config.expected_units = 'kwh'
    readings = [reading, reading.dup.tap { |r| r[4] = 'LEAD' }]
    results = described_class.new(sheffield_config, readings).perform
    expect(results.size).to eq(1)
    expect(results.first[:readings].first).to eq('1.20800000')
  end

  it 'handles trailing whitespace on the MPAN' do
    reading[1] = "#{reading[1]} "
    result = described_class.new(sheffield_config, [reading]).perform.first
    expect(result[:mpan_mprn]).to eq('2333300681718')
  end

  context 'for Opus gas feed' do
    let(:opus_gas_config) do
      build(:amr_data_feed_config,
            description: 'Opus gas',
            date_format: '%d/%m/%Y',
            mpan_mprn_field: 'MPAN',
            reading_date_field: 'ReadingDate',
            reading_time_field: 'ReadTime',
            reading_fields: ['MeterConsumption'],
            header_example: 'MPAN,ReadingDate,ReadTime,MeterConsumption',
            row_per_reading: true,
            positional_index: true)
    end

    let!(:meter_1) { create(:solar_pv_meter, meter_serial_number: '10070831') }
    let!(:meter_2) { create(:solar_pv_meter, meter_serial_number: '10070839') }

    it 'picks imports only, from every other column' do
      readings = [
        # ['MPAN,ReadingDate,ReadTime,MeterConsumption'],
        ['10070831', '01/05/2023', '530', '0.001'],
        ['10070831', '01/05/2023', '600', '0'],
        ['10070831', '01/05/2023', '630', '0'],
        ['10070831', '01/05/2023', '700', '0'],
        ['10070831', '01/05/2023', '730', '11.1922'],
        ['10070831', '01/05/2023', '800', '0'],
        ['10070831', '01/05/2023', '830', '0'],
        ['10070831', '01/05/2023', '900', '0'],
        ['10070831', '01/05/2023', '930', '0'],
        ['10070831', '01/05/2023', '1000', '0'],
        ['10070831', '01/05/2023', '1030', '11.1922'],
        ['10070831', '01/05/2023', '1100', '0'],
        ['10070831', '01/05/2023', '1130', '0'],
        ['10070831', '01/05/2023', '1200', '0'],
        ['10070831', '01/05/2023', '1230', '0'],
        ['10070831', '01/05/2023', '1300', '0'],
        ['10070831', '01/05/2023', '1330', '0'],
        ['10070831', '01/05/2023', '1400', '11.1922'],
        ['10070831', '01/05/2023', '1430', '0'],
        ['10070831', '01/05/2023', '1500', '0'],
        ['10070831', '01/05/2023', '1530', '0'],
        ['10070831', '01/05/2023', '1600', '0'],
        ['10070831', '01/05/2023', '1630', '0'],
        ['10070831', '01/05/2023', '1700', '11.1922'],
        ['10070831', '01/05/2023', '1730', '0'],
        ['10070831', '01/05/2023', '1800', '0'],
        ['10070831', '01/05/2023', '1830', '0'],
        ['10070831', '01/05/2023', '1900', '0'],
        ['10070831', '01/05/2023', '1930', '0'],
        ['10070831', '01/05/2023', '2000', '0'],
        ['10070831', '01/05/2023', '2030', '11.1922'],
        ['10070831', '01/05/2023', '2100', '0'],
        ['10070831', '01/05/2023', '2130', '0'],
        ['10070831', '01/05/2023', '2200', '0'],
        ['10070831', '01/05/2023', '2230', '0'],
        ['10070831', '01/05/2023', '2300', '11.1922'],
        ['10070831', '01/05/2023', '2330', '0'],
        ['10070831', '02/05/2023', '0', '0'],
        ['10070831', '02/05/2023', '30', '0'],
        ['10070831', '02/05/2023', '100', '0'],
        ['10070831', '02/05/2023', '130', '0'],
        ['10070831', '02/05/2023', '200', '0'],
        ['10070831', '02/05/2023', '230', '0'],
        ['10070831', '02/05/2023', '300', '11.1922'],
        ['10070831', '02/05/2023', '330', '0'],
        ['10070831', '02/05/2023', '400', '0'],
        ['10070831', '02/05/2023', '430', '0'],
        ['10070831', '02/05/2023', '500', '0'],
        ['10070831', '02/05/2023', '530', '67.1534'],
        ['10070831', '02/05/2023', '600', '190.268'],
        ['10070831', '02/05/2023', '630', '179.076'],
        ['10070831', '02/05/2023', '700', '123.114'],
        ['10070831', '02/05/2023', '730', '111.922'],
        ['10070831', '02/05/2023', '800', '111.922'],
        ['10070831', '02/05/2023', '830', '111.922'],
        ['10070831', '02/05/2023', '900', '100.73'],
        ['10070831', '02/05/2023', '930', '111.922'],
        ['10070831', '02/05/2023', '1000', '100.73'],
        ['10070831', '02/05/2023', '1030', '111.922'],
        ['10070831', '02/05/2023', '1100', '100.73'],
        ['10070831', '02/05/2023', '1130', '100.73'],
        ['10070831', '02/05/2023', '1200', '11.1922'],
        ['10070831', '02/05/2023', '1230', '0'],
        ['10070831', '02/05/2023', '1300', '0'],
        ['10070831', '02/05/2023', '1330', '11.1922'],
        ['10070831', '02/05/2023', '1400', '0'],
        ['10070831', '02/05/2023', '1430', '0'],
        ['10070831', '02/05/2023', '1500', '0'],
        ['10070831', '02/05/2023', '1530', '0'],
        ['10070831', '02/05/2023', '1600', '11.1922'],
        ['10070831', '02/05/2023', '1630', '0'],
        ['10070831', '02/05/2023', '1700', '0'],
        ['10070831', '02/05/2023', '1730', '0'],
        ['10070831', '02/05/2023', '1800', '0'],
        ['10070831', '02/05/2023', '1830', '0'],
        ['10070831', '02/05/2023', '1900', '0'],
        ['10070831', '02/05/2023', '1930', '0'],
        ['10070831', '02/05/2023', '2000', '11.1922'],
        ['10070831', '02/05/2023', '2030', '0'],
        ['10070831', '02/05/2023', '2100', '0'],
        ['10070831', '02/05/2023', '2130', '0'],
        ['10070831', '02/05/2023', '2200', '0'],
        ['10070831', '02/05/2023', '2230', '0'],
        ['10070831', '02/05/2023', '2300', '0'],
        ['10070831', '02/05/2023', '2330', '11.1922']
      ]
      results = described_class.new(opus_gas_config, readings).perform

      expect(results.size).to eq(85)

      expect(results.first[:mpan_mprn]).to eq('10070831')
      expect(results.first[:reading_date]).to eq('01/05/2023')
      expect(results.first[:reading_time]).to eq('530')
      expect(results.first[:readings]).to eq(['0.001'])

      expect(results.last[:mpan_mprn]).to eq('10070831')
      expect(results.last[:reading_date]).to eq('02/05/2023')
      expect(results.last[:reading_time]).to eq('2330')
      expect(results.last[:readings]).to eq(['11.1922'])
    end
  end

  context 'for MyCorona feed' do
    let(:mycorona_config) do
      build(:amr_data_feed_config,
            description: 'MyCorona portal',
            date_format: '%d/%m/%Y',
            mpan_mprn_field: 'Site Name',
            reading_date_field: 'Read date',
            reading_time_field: 'Time',
            reading_fields: [' Actual (KWH)'],
            header_example: 'Read date,Time,Site Name, Actual (KWH)',
            row_per_reading: true,
            positional_index: true)
    end

    let!(:meter_1) { create(:solar_pv_meter, meter_serial_number: '10070831') }
    let!(:meter_2) { create(:solar_pv_meter, meter_serial_number: '10070839') }

    it 'picks imports only, from every other column' do
      half_hours = (0..23).map { |hour| [format('%02d:00', hour), format('%02d:30', hour)] }.flatten
      readings = ['01/06/2023', '02/06/2023'].flat_map do |date|
        half_hours.map.with_index do |time, i|
          # ['Read date', 'Time', 'Site Name', ' Actual (KWH)']
          [date, time, '10070831', "0.#{format('%03d', (i + 1))}"]
        end
      end

      results = described_class.new(mycorona_config, readings).perform

      expect(results.size).to eq(96)

      expect(results.first[:mpan_mprn]).to eq('10070831')
      expect(results.first[:reading_date]).to eq('01/06/2023')
      expect(results.first[:reading_time]).to eq('00:00')
      expect(results.first[:readings]).to eq(['0.001'])

      expect(results.last[:mpan_mprn]).to eq('10070831')
      expect(results.last[:reading_date]).to eq('02/06/2023')
      expect(results.last[:reading_time]).to eq('23:30')
      expect(results.last[:readings]).to eq(['0.048'])
    end
  end

  context 'for EfT solar feed' do
    let(:eft_config) do
      build(:amr_data_feed_config,
            description: 'EfT',
            date_format: '%H:%M:%S %a %d/%m/%Y',
            mpan_mprn_field: '',
            units_field: 'units',
            reading_date_field: 'DateTime',
            reading_fields: reading_fields,
            meter_description_field: 'Description',
            header_example: "Description,SerialNumber,DateTime,import_total,export_total,#{reading_fields.join(',_,')}",
            expected_units: '',
            msn_field: 'SerialNumber',
            lookup_by_serial_number: true)
    end
    let!(:meters) do
      [create(:solar_pv_meter, meter_serial_number: '10070831'),
       create(:solar_pv_meter, meter_serial_number: '10070839')]
    end
    let(:readings) do
      [
        ['10070831', '10070831', '00:13:07 Thu 07/04/2022', '83294159.417', '0',
         '0.000000', '0.000000', '0.000000', '0.000000', '0.000000', '0.000000', '0.000000', '0.000000',
         '0.000000', '0.000000', '0.000000', '0.000000', '0.000000', '0.000000', '0.000000', '0.000000',
         '0.000000', '0.000000', '0.000000', '0.000000', '0.000000', '0.000000', '0.000000', '0.000000',
         '0.121895', '0.000000', '0.399635', '0.000000', '0.756100', '0.000000', '1.137950', '0.000000',
         '1.524650', '0.000000', '1.825500', '0.000000', '1.618100', '0.000000', '1.478200', '0.000000',
         '2.088200', '0.000000', '2.045800', '0.000000', '2.190850', '0.000000', '2.860450', '0.000000',
         '2.912200', '0.000000', '1.213350', '0.000000', '1.885650', '0.000000', '2.116800', '0.000000',
         '1.517650', '0.000000', '1.855550', '0.000000', '1.435450', '0.000000', '1.340200', '0.000000',
         '0.933100', '0.000000', '0.760450', '0.000000', '0.548250', '0.000000', '0.110745', '0.000000',
         '0.035366', '0.000000', '0.000000', '0.000000', '0.000000', '0.000000', '0.000000', '0.000000',
         '0.000000', '0.000000', '0.000000', '0.000000', '0.000000', '0.000000', '0.000000', '0.000000',
         '0.000000', '0.000000', '0.000000', '0.000000', '0.000000', '0.000000', '0.000000', '0.000000'],
        ['10070839', '10070839', '00:10:58 Thu 07/04/2022', '84079387.609', '0',
         '0.000000', '0.000000', '0.000000', '0.000000', '0.000000', '0.000000', '0.000000', '0.000000',
         '0.000000', '0.000000', '0.000000', '0.000000', '0.000000', '0.000000', '0.000000', '0.000000',
         '0.000000', '0.000000', '0.000000', '0.000000', '0.000000', '0.000000', '0.066830', '0.000000',
         '0.036760', '0.000000', '0.741800', '0.000000', '0.703950', '0.000000', '1.255700', '0.000000',
         '2.213050', '0.000000', '2.983500', '0.000000', '2.985250', '0.000000', '3.140100', '0.000000',
         '3.415300', '0.000000', '3.449850', '0.000000', '3.144750', '0.000000', '2.859600', '0.000000',
         '2.685850', '0.000000', '3.200550', '0.000000', '2.425800', '0.000000', '2.163900', '0.000000',
         '1.110500', '0.000000', '0.995000', '0.000000', '0.985400', '0.000000', '0.696800', '0.000000',
         '0.343965', '0.000000', '0.430185', '0.000000', '0.340685', '0.000000', '0.215565', '0.000000',
         '0.091900', '0.000000', '0.004118', '0.000000', '0.000000', '0.000000', '0.000000', '0.000000',
         '0.000000', '0.000000', '0.000000', '0.000000', '0.000000', '0.000000', '0.000000', '0.000000',
         '0.000000', '0.000000', '0.000000', '0.000000', '0.000000', '0.000000', '0.000000', '0.000000']
      ]
    end

    it 'picks imports only, from every other column' do
      results = described_class.new(eft_config, readings).perform

      expect(results.size).to eq(2)
      expect(results.first[:readings].count).to eq(48)
      expect(results.first[:meter_serial_number]).to eq('10070831')
      expect(results.first[:readings][12]).to eq('0.121895')
      expect(results.first[:readings][13]).to eq('0.399635')
      expect(results.first[:readings][14]).to eq('0.756100')
      expect(results.second[:readings].count).to eq(48)
      expect(results.second[:meter_serial_number]).to eq('10070839')
      expect(results.second[:readings][11]).to eq('0.066830')
      expect(results.second[:readings][12]).to eq('0.036760')
      expect(results.second[:readings][13]).to eq('0.741800')
    end

    it 'finds correct meter id and mpan from serial number' do
      results = described_class.new(eft_config, readings).perform

      expect(results.size).to eq(2)

      expect(results.first[:meter_id]).to eq(meters[0].id)
      expect(results.first[:mpan_mprn]).to eq(meters[0].mpan_mprn.to_s)
      expect(results.first[:meter_serial_number]).to eq('10070831')

      expect(results.second[:meter_id]).to eq(meters[1].id)
      expect(results.second[:mpan_mprn]).to eq(meters[1].mpan_mprn.to_s)
      expect(results.second[:meter_serial_number]).to eq('10070839')
    end

    it 'handles missing meter' do
      readings[0][0] = readings[0][1] = '1234'
      readings[1][0] = readings[1][1] = '5678'

      results = described_class.new(eft_config, readings).perform

      expect(results.size).to eq(2)

      expect(results.first[:meter_id]).to be_nil
      expect(results.first[:mpan_mprn]).to be_nil
      expect(results.first[:meter_serial_number]).to eq('1234')

      expect(results.second[:meter_id]).to be_nil
      expect(results.second[:mpan_mprn]).to be_nil
      expect(results.second[:meter_serial_number]).to eq('5678')
    end

    it 'raises error if duplicate serial numbers found' do
      create(:solar_pv_meter, meter_serial_number: meters[0].meter_serial_number)
      expect do
        described_class.new(eft_config, [readings.first]).perform
      end.to raise_error(Amr::DataFeedException)
    end

    it 'handles trailing whitespace on the meter serial' do
      readings[0][1] = "#{readings[0][1]} "
      results = described_class.new(eft_config, readings).perform
      expect(results.first[:meter_serial_number]).to eq('10070831')
    end
  end
end
