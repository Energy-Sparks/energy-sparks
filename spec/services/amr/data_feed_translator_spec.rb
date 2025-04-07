# frozen_string_literal: true

require 'rails_helper'

describe Amr::DataFeedTranslator do
  let(:config) do
    reading_fields = (1..48).map { |i| "kWh_#{i}" }
    build(:amr_data_feed_config,
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

  describe '#perform' do
    subject(:results) do
      described_class.new(config, readings).perform
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

    let(:readings) { [reading] }

    it 'converts the array of rows to a keyed hash' do
      result = results.first
      expect(result[:mpan_mprn]).to eq('2333300681718')
      expect(result[:reading_date]).to eq('31/12/2019')
      expect(result[:description]).to eq('MEERSBROOK PRIMARY - M1')
      expect(result[:readings].first).to eq('1.20800000')
      expect(result[:readings].last).to eq('1.17700000')
      expect(result[:units]).to eq('kwh')
    end

    it 'removes trailing whitespace from the MPAN' do
      reading[1] = "#{reading[1]} "
      expect(results.first[:mpan_mprn]).to eq('2333300681718')
    end

    context 'when the config has a positional index' do
      it 'adds period to hash' do
        config.positional_index = true
        expect(results.first[:period]).to eq('1')
      end
    end

    context 'when the config is a row per reading format with a separate reading time' do
      let(:config) do
        build(:amr_data_feed_config,
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

      let(:readings) do
        half_hours = (0..23).map { |hour| [format('%02d:00', hour), format('%02d:30', hour)] }.flatten
        ['01/06/2023', '02/06/2023'].flat_map do |date|
          half_hours.map.with_index do |time, i|
            # ['Read date', 'Time', 'Site Name', ' Actual (KWH)']
            [date, time, '10070831', "0.#{format('%03d', (i + 1))}"]
          end
        end
      end

      it 'parses into a hash with date, time and single readings' do
        expect(results.size).to eq(readings.size)

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

    context 'when the config defines expected units' do
      let(:readings) do
        [reading, reading.dup.tap { |r| r[4] = 'LEAD' }]
      end

      it 'removes rows that do not match the expected_units' do
        config.expected_units = 'kwh'
        expect(results.size).to eq(1)
        expect(results.first[:readings].first).to eq('1.20800000')
      end
    end

    context 'when the config uses serial numbers' do
      let(:config) do
        reading_fields = (1..48).map { |i| "kWh_#{i}" }
        build(:amr_data_feed_config,
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

      it 'parses into a hash with serial number' do
        expect(results.size).to eq(readings.size)
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
        expect(results.size).to eq(readings.size)

        expect(results.first[:meter_id]).to eq(meters[0].id)
        expect(results.first[:mpan_mprn]).to eq(meters[0].mpan_mprn.to_s)
        expect(results.first[:meter_serial_number]).to eq('10070831')

        expect(results.second[:meter_id]).to eq(meters[1].id)
        expect(results.second[:mpan_mprn]).to eq(meters[1].mpan_mprn.to_s)
        expect(results.second[:meter_serial_number]).to eq('10070839')
      end

      it 'handles missing meter serial numbers' do
        readings[0][0] = readings[0][1] = '1234'
        readings[1][0] = readings[1][1] = '5678'

        expect(results.size).to eq(readings.size)

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
          described_class.new(config, [readings.first]).perform
        end.to raise_error(Amr::DataFeedException)
      end

      it 'handles trailing whitespace on the meter serial' do
        readings[0][1] = "#{readings[0][1]} "
        expect(results.first[:meter_serial_number]).to eq('10070831')
      end
    end

    context 'when converting rows to kwh' do
      before do
        config.convert_to_kwh = :m3
      end

      context 'when no units field is specified for each row' do
        before do
          config.units_field = nil
          config.expected_units = nil
        end

        it 'converts all rows to kwh' do
          expect(results.size).to eq(readings.size)
          expect(results.first[:readings].first).to be_within(0.0001).of(13.4087)
        end
      end

      context 'when there are different units per row' do
        # one row kwh, one row m3
        let(:readings) do
          [reading, reading.dup.tap { |r| r[4] = 'm3' }]
        end

        it 'converts only specific m3 rows to kwh' do
          expect(results.size).to eq(readings.size)
          expect(results.first[:units]).to eq('kwh')
          expect(results.first[:readings].first).to eq('1.20800000')
          expect(results.last[:units]).to eq('kwh')
          expect(results.last[:readings].first).to be_within(0.0001).of(13.4087)
        end
      end

      context 'when using the meter gas unit' do
        before do
          config.convert_to_kwh = :meter
        end

        it 'converts ft3' do
          create(:gas_meter, mpan_mprn: reading[1], gas_unit: :ft3)
          expect(results.first[:readings].first).to be_within(0.0001).of(0.3797)
        end

        it 'converts hcf' do
          create(:gas_meter, mpan_mprn: reading[1], gas_unit: :hcf)
          expect(results.first[:readings].first).to be_within(0.01).of(37.97)
        end
      end
    end

    context 'when the config indicates there are delayed readings' do
      before do
        config.delayed_reading = true
      end

      it 'reformats the dates' do
        expect(results.first[:reading_date]).to eq('30/12/2019')
      end

      context 'with a date time format' do
        let(:reading) do
          ['MEERSBROOK PRIMARY - M1', '2333300681718', '2023-09-12T01:05:02Z', '1', 'kwh',
           '1.20800000', '1.16100000', '1.19500000', '1.21000000', '1.16600000', '1.20100000',
           '1.17800000', '1.30000000', '1.30100000', '1.26600000', '1.27300000', '1.28000000',
           '2.10900000', '2.03700000', '1.29100000', '1.24600000', '1.67800000', '1.24500000',
           '1.12800000', '1.11300000', '1.35000000', '1.11700000', '1.14200000', '1.40600000',
           '1.10100000', '1.12300000', '1.16400000', '1.42700000', '1.12900000', '1.10400000',
           '1.11900000', '1.46600000', '1.18400000', '1.14600000', '1.22600000', '1.20800000',
           '1.25500000', '1.20000000', '1.23600000', '1.16300000', '1.12400000', '1.19800000',
           '1.12800000', '1.15500000', '1.13000000', '1.18200000', '1.14500000', '1.17700000'] + ([''] * 48)
        end

        before do
          config.date_format = '%Y-%m-%dT%H:%M:%SZ'
        end

        it 'reformats the dates' do
          expect(results.first[:reading_date]).to eq('2023-09-11T01:05:02Z')
        end
      end
    end
  end
end
