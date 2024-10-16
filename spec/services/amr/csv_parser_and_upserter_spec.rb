require 'rails_helper'
require 'fileutils'
require 'fakefs/spec_helpers'

module Amr
  describe CsvParserAndUpserter do
    include FakeFS::SpecHelpers

    let(:file_name) { 'example.csv' }
    let!(:config) do
      create(:amr_data_feed_config,
        description: 'BANES',
        mpan_mprn_field: 'M1_Code1',
        reading_date_field: 'Date',
        date_format: '%b %e %Y %I:%M%p',
        number_of_header_rows: 1,
        provider_id_field: 'ID',
        total_field: 'Total',
        meter_description_field: 'Location',
        postcode_field: 'PostCode',
        units_field: 'Units',
        header_example: 'ID,Date,Location,Type,PostCode,Units,Total Units,[00:30],[01:00],[01:30],[02:00],[02:30],[03:00],[03:30],[04:00],[04:30],[05:00],[05:30],[06:00],[06:30],[07:00],[07:30],[08:00],[08:30],[09:00],[09:30],[10:00],[10:30],[11:00],[11:30],[12:00],[12:30],[13:00],[13:30],[14:00],[14:30],[15:00],[15:30],[16:00],[16:30],[17:00],[17:30],[18:00],[18:30],[19:00],[19:30],[20:00],[20:30],[21:00],[21:30],[22:00],[22:30],[23:00],[23:30],[24:00],M1_Code1,M1_Code2',
        reading_fields: '[00:30],[01:00],[01:30],[02:00],[02:30],[03:00],[03:30],[04:00],[04:30],[05:00],[05:30],[06:00],[06:30],[07:00],[07:30],[08:00],[08:30],[09:00],[09:30],[10:00],[10:30],[11:00],[11:30],[12:00],[12:30],[13:00],[13:30],[14:00],[14:30],[15:00],[15:30],[16:00],[16:30],[17:00],[17:30],[18:00],[18:30],[19:00],[19:30],[20:00],[20:30],[21:00],[21:30],[22:00],[22:30],[23:00],[23:30],[24:00]'.split(',')
      )
    end

    let!(:frome_config) do
      create(:amr_data_feed_config,
        description: 'Frome',
        date_format: '%d/%m/%y',
        mpan_mprn_field: 'Site Id',
        msn_field: 'Meter Number',
        reading_date_field: 'Reading Date',
        number_of_header_rows: 0,
        reading_fields:  '00:00,00:30,01:00,01:30,02:00,02:30,03:00,03:30,04:00,04:30,05:00,05:30,06:00,06:30,07:00,07:30,08:00,08:30,09:00,09:30,10:00,10:30,11:00,11:30,12:00,12:30,13:00,13:30,14:00,14:30,15:00,15:30,16:00,16:30,17:00,17:30,18:00,18:30,19:00,19:30,20:00,20:30,21:00,21:30,22:00,22:30,23:00,23:30'.split(','),
        header_example: 'Site Id,Meter Number,Reading Date,00:00,00:30,01:00,01:30,02:00,02:30,03:00,03:30,04:00,04:30,05:00,05:30,06:00,06:30,07:00,07:30,08:00,08:30,09:00,09:30,10:00,10:30,11:00,11:30,12:00,12:30,13:00,13:30,14:00,14:30,15:00,15:30,16:00,16:30,17:00,17:30,18:00,18:30,19:00,19:30,20:00,20:30,21:00,21:30,22:00,22:30,23:00,23:30',
      )
    end

    let!(:historical_frome_config) do
      create(:amr_data_feed_config,
        description: 'Frome Historical',
        date_format: '%d/%m/%Y',
        mpan_mprn_field: 'Site Id',
        msn_field: 'Meter Number',
        reading_date_field: 'Reading Date',
        handle_off_by_one: true,
        reading_fields:  '00:00,00:30,01:00,01:30,02:00,02:30,03:00,03:30,04:00,04:30,05:00,05:30,06:00,06:30,07:00,07:30,08:00,08:30,09:00,09:30,10:00,10:30,11:00,11:30,12:00,12:30,13:00,13:30,14:00,14:30,15:00,15:30,16:00,16:30,17:00,17:30,18:00,18:30,19:00,19:30,20:00,20:30,21:00,21:30,22:00,22:30,23:00,23:30'.split(','),
        header_example: 'Site Id,Meter Number,Reading Date,00:00,00:30,01:00,01:30,02:00,02:30,03:00,03:30,04:00,04:30,05:00,05:30,06:00,06:30,07:00,07:30,08:00,08:30,09:00,09:30,10:00,10:30,11:00,11:30,12:00,12:30,13:00,13:30,14:00,14:30,15:00,15:30,16:00,16:30,17:00,17:30,18:00,18:30,19:00,19:30,20:00,20:30,21:00,21:30,22:00,22:30,23:00,23:30',
      )
    end

    let!(:sheffield_config) do
      create(:amr_data_feed_config,
        description: 'Sheffield',
        date_format: '%d/%m/%Y',
        mpan_mprn_field: 'MPAN',
        reading_date_field: 'ConsumptionDate',
        reading_fields:   'kWh_1,kWh_2,kWh_3,kWh_4,kWh_5,kWh_6,kWh_7,kWh_8,kWh_9,kWh_10,kWh_11,kWh_12,kWh_13,kWh_14,kWh_15,kWh_16,kWh_17,kWh_18,kWh_19,kWh_20,kWh_21,kWh_22,kWh_23,kWh_24,kWh_25,kWh_26,kWh_27,kWh_28,kWh_29,kWh_30,kWh_31,kWh_32,kWh_33,kWh_34,kWh_35,kWh_36,kWh_37,kWh_38,kWh_39,kWh_40,kWh_41,kWh_42,kWh_43,kWh_44,kWh_45,kWh_46,kWh_47,kWh_48'.split(','),
        meter_description_field: 'siteRef',
        header_example: 'siteRef,MPAN,ConsumptionDate,kWh_1,kWh_2,kWh_3,kWh_4,kWh_5,kWh_6,kWh_7,kWh_8,kWh_9,kWh_10,kWh_11,kWh_12,kWh_13,kWh_14,kWh_15,kWh_16,kWh_17,kWh_18,kWh_19,kWh_20,kWh_21,kWh_22,kWh_23,kWh_24,kWh_25,kWh_26,kWh_27,kWh_28,kWh_29,kWh_30,kWh_31,kWh_32,kWh_33,kWh_34,kWh_35,kWh_36,kWh_37,kWh_38,kWh_39,kWh_40,kWh_41,kWh_42,kWh_43,kWh_44,kWh_45,kWh_46,kWh_47,kWh_48,kVArh_1,kVArh_2,kVArh_3,kVArh_4,kVArh_5,kVArh_6,kVArh_7,kVArh_8,kVArh_9,kVArh_10,kVArh_11,kVArh_12,kVArh_13,kVArh_14,kVArh_15,kVArh_16,kVArh_17,kVArh_18,kVArh_19,kVArh_20,kVArh_21,kVArh_22,kVArh_23,kVArh_24,kVArh_25,kVArh_26,kVArh_27,kVArh_28,kVArh_29,kVArh_30,kVArh_31,kVArh_32,kVArh_33,kVArh_34,kVArh_35,kVArh_36,kVArh_37,kVArh_38,kVArh_39,kVArh_40,kVArh_41,kVArh_42,kVArh_43,kVArh_44,kVArh_45,kVArh_46,kVArh_47,kVArh_48'
      )
    end

    let!(:sheffield_gas_config) do
      create(:amr_data_feed_config,
        description: 'Sheffield Gas',
        date_format: '%d/%m/%Y',
        mpan_mprn_field: '"MPR"',
        reading_date_field: '"Date"',
        reading_fields: '"hr0030","hr0100","hr0130","hr0200","hr0230","hr0300","hr0330","hr0400","hr0430","hr0500","hr0530","hr0600","hr0630","hr0700","hr0730","hr0800","hr0830","hr0900","hr0930","hr1000","hr1030","hr1100","hr1130","hr1200","hr1230","hr1300","hr1330","hr1400","hr1430","hr1500","hr1530","hr1600","hr1630","hr1700","hr1730","hr1800","hr1830","hr1900","hr1930","hr2000","hr2030","hr2100","hr2130","hr2200","hr2230","hr2300","hr2330","hr0000"'.split(','),
        header_example: '"MPR","Date","hr0030","hr0100","hr0130","hr0200","hr0230","hr0300","hr0330","hr0400","hr0430","hr0500","hr0530","hr0600","hr0630","hr0700","hr0730","hr0800","hr0830","hr0900","hr0930","hr1000","hr1030","hr1100","hr1130","hr1200","hr1230","hr1300","hr1330","hr1400","hr1430","hr1500","hr1530","hr1600","hr1630","hr1700","hr1730","hr1800","hr1830","hr1900","hr1930","hr2000","hr2030","hr2100","hr2130","hr2200","hr2230","hr2300","hr2330","hr0000"'
      )
    end

    let!(:highlands_config) do
      create(:amr_data_feed_config,
        description: 'Highlands',
        date_format: '%e %b %Y %H:%M:%S',
        mpan_mprn_field: 'MPR',
        reading_date_field: 'ReadDatetime',
        reading_fields: ['kWh'],
        header_example: 'MPR,ReadDatetime,kWh,ReadType',
        row_per_reading: true,
        number_of_header_rows: 2,
        identifier: 'amr_highlands'
      )
    end

    let!(:solar_for_schools_config) do
      create(:amr_data_feed_config,
        description: 'Solar for Schools',
        date_format: '%d %m %Y',
        mpan_mprn_field: 'MPAN',
        reading_date_field: 'date',
        reading_fields: '12:00 AM,12:30 AM,1:00 AM,1:30 AM,2:00 AM,2:30 AM,3:00 AM,3:30 AM,4:00 AM,4:30 AM,5:00 AM,5:30 AM,6:00 AM,6:30 AM,7:00 AM,7:30 AM,8:00 AM,8:30 AM,9:00 AM,9:30 AM,10:00 AM,10:30 AM,11:00 AM,11:30 AM,12:00 PM,12:30 PM,1:00 PM,1:30 PM,2:00 PM,2:30 PM,3:00 PM,3:30 PM,4:00 PM,4:30 PM,5:00 PM,5:30 PM,6:00 PM,6:30 PM,7:00 PM,7:30 PM,8:00 PM,8:30 PM,9:00 PM,9:30 PM,10:00 PM,10:30 PM,11:00 PM,11:30 PM'.split(','),
        header_example: 'id,name,date,type,MPAN,12:00 AM,12:30 AM,1:00 AM,1:30 AM,2:00 AM,2:30 AM,3:00 AM,3:30 AM,4:00 AM,4:30 AM,5:00 AM,5:30 AM,6:00 AM,6:30 AM,7:00 AM,7:30 AM,8:00 AM,8:30 AM,9:00 AM,9:30 AM,10:00 AM,10:30 AM,11:00 AM,11:30 AM,12:00 PM,12:30 PM,1:00 PM,1:30 PM,2:00 PM,2:30 PM,3:00 PM,3:30 PM,4:00 PM,4:30 PM,5:00 PM,5:30 PM,6:00 PM,6:30 PM,7:00 PM,7:30 PM,8:00 PM,8:30 PM,9:00 PM,9:30 PM,10:00 PM,10:30 PM,11:00 PM,11:30 PM',
        number_of_header_rows: 1,
        meter_description_field: 'name',
        identifier: 'solar_for_schools'
      )
    end

    def write_file_and_expect_readings(csv, config, first_reading = '0.165', reading_count = 1)
      record_count = write_file_and_parse(csv, config)
      expect(AmrDataFeedReading.count).to be reading_count
      expect(record_count).to be reading_count
      expect(AmrDataFeedReading.first.readings.first).to eq first_reading
      expect(AmrDataFeedImportLog.count).to be 1
      log = AmrDataFeedImportLog.first
      expect(log.file_name).to eq file_name
      expect(log.amr_data_feed_config_id).to be config.id
      expect(log.records_imported).to be reading_count
    end

    def write_file_and_expect_updated_readings(csv, config, updated_reading = '0.166')
      update_file_name = 'updated-example.csv'
      write_file_and_parse(csv, config, update_file_name)
      expect(AmrDataFeedReading.count).to be 1
      expect(AmrDataFeedReading.first.readings.first).to eq updated_reading
      expect(AmrDataFeedImportLog.count).to be 2
      first_import_log = AmrDataFeedImportLog.find_by(file_name: file_name)

      expect(first_import_log.amr_data_feed_config_id).to be config.id
      expect(first_import_log.records_imported).to be 1
      expect(first_import_log.records_updated).to be 0
      second_import_log = AmrDataFeedImportLog.find_by(file_name: update_file_name)

      expect(second_import_log.amr_data_feed_config_id).to be config.id
      expect(second_import_log.records_imported).to be 0
      expect(second_import_log.records_updated).to be 1
    end

    def write_file_and_parse(csv, config, import_file_name = file_name)
      File.write("#{config.local_bucket_path}/#{import_file_name}", csv)
      importer = CsvParserAndUpserter.new(config, import_file_name)
      importer.perform
      importer.inserted_record_count
    end

    context 'highlands with real files' do
      it 'imports a csv' do
        FakeFS.deactivate!
        ClimateControl.modify AMR_CONFIG_LOCAL_FILE_BUCKET_PATH: 'spec/fixtures' do
          expect(AmrDataFeedReading.count).to be 0
          importer = CsvParserAndUpserter.new(highlands_config, 'example.csv')
          importer.perform

          AmrDataFeedReading.all.find_each do |reading_record|
            expect(reading_record.readings.any?(&:blank?)).to be false
          end

          expect(AmrDataFeedReading.count).to be 10
          expect(importer.inserted_record_count).to be 10
        end
        FakeFS.activate!
      end

      it 'imports a csv where the times are shifted by half an hour' do
        FakeFS.deactivate!
        ClimateControl.modify AMR_CONFIG_LOCAL_FILE_BUCKET_PATH: 'spec/fixtures' do
          expect(AmrDataFeedReading.count).to be 0
          importer = CsvParserAndUpserter.new(highlands_config, 'example-offset.csv')
          importer.perform

          AmrDataFeedReading.all.find_each do |reading_record|
            expect(reading_record.readings.count(&:blank?)).to be <= highlands_config.blank_threshold
          end

          expect(AmrDataFeedReading.count).to be 7
          expect(importer.inserted_record_count).to be 7
        end
        FakeFS.activate!
      end

      it 'record exception when file is truncated' do
        FakeFS.deactivate!
        ClimateControl.modify AMR_CONFIG_LOCAL_FILE_BUCKET_PATH: 'spec/fixtures' do
          expect(AmrDataFeedReading.count).to be 0
          importer = CsvParserAndUpserter.new(highlands_config, 'empty.csv')
          importer.perform

          expect(AmrDataFeedReading.count).to be 0
          expect(importer.inserted_record_count).to be 0
          expect(AmrDataFeedImportLog.last.error_messages).not_to be_nil
        end
        FakeFS.activate!
      end

      it 'record exception when file is invalid' do
        FakeFS.deactivate!
        ClimateControl.modify AMR_CONFIG_LOCAL_FILE_BUCKET_PATH: 'spec/fixtures' do
          expect(AmrDataFeedReading.count).to be 0

          e = StandardError.new
          expect_any_instance_of(Amr::DataFileToAmrReadingData).to receive(:perform).and_raise(e)

          importer = CsvParserAndUpserter.new(highlands_config, 'empty.csv')
          expect { importer.perform }.to raise_error StandardError

          expect(AmrDataFeedReading.count).to be 0
          expect(importer.inserted_record_count).to be 0
        end
        FakeFS.activate!
      end
    end

    context 'sheffield' do
      def sheffield_empty_readings
        <<~HEREDOC
          siteRef,MPAN,ConsumptionDate,kWh_1,kWh_2,kWh_3,kWh_4,kWh_5,kWh_6,kWh_7,kWh_8,kWh_9,kWh_10,kWh_11,kWh_12,kWh_13,kWh_14,kWh_15,kWh_16,kWh_17,kWh_18,kWh_19,kWh_20,kWh_21,kWh_22,kWh_23,kWh_24,kWh_25,kWh_26,kWh_27,kWh_28,kWh_29,kWh_30,kWh_31,kWh_32,kWh_33,kWh_34,kWh_35,kWh_36,kWh_37,kWh_38,kWh_39,kWh_40,kWh_41,kWh_42,kWh_43,kWh_44,kWh_45,kWh_46,kWh_47,kWh_48,kVArh_1,kVArh_2,kVArh_3,kVArh_4,kVArh_5,kVArh_6,kVArh_7,kVArh_8,kVArh_9,kVArh_10,kVArh_11,kVArh_12,kVArh_13,kVArh_14,kVArh_15,kVArh_16,kVArh_17,kVArh_18,kVArh_19,kVArh_20,kVArh_21,kVArh_22,kVArh_23,kVArh_24,kVArh_25,kVArh_26,kVArh_27,kVArh_28,kVArh_29,kVArh_30,kVArh_31,kVArh_32,kVArh_33,kVArh_34,kVArh_35,kVArh_36,kVArh_37,kVArh_38,kVArh_39,kVArh_40,kVArh_41,kVArh_42,kVArh_43,kVArh_44,kVArh_45,kVArh_46,kVArh_47,kVArh_48
          HIGH STORRS ROAD,2331031705716,01/10/2015,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
        HEREDOC
      end

      def sheffield_one_empty_reading
        <<~HEREDOC
          siteRef,MPAN,ConsumptionDate,kWh_1,kWh_2,kWh_3,kWh_4,kWh_5,kWh_6,kWh_7,kWh_8,kWh_9,kWh_10,kWh_11,kWh_12,kWh_13,kWh_14,kWh_15,kWh_16,kWh_17,kWh_18,kWh_19,kWh_20,kWh_21,kWh_22,kWh_23,kWh_24,kWh_25,kWh_26,kWh_27,kWh_28,kWh_29,kWh_30,kWh_31,kWh_32,kWh_33,kWh_34,kWh_35,kWh_36,kWh_37,kWh_38,kWh_39,kWh_40,kWh_41,kWh_42,kWh_43,kWh_44,kWh_45,kWh_46,kWh_47,kWh_48,kVArh_1,kVArh_2,kVArh_3,kVArh_4,kVArh_5,kVArh_6,kVArh_7,kVArh_8,kVArh_9,kVArh_10,kVArh_11,kVArh_12,kVArh_13,kVArh_14,kVArh_15,kVArh_16,kVArh_17,kVArh_18,kVArh_19,kVArh_20,kVArh_21,kVArh_22,kVArh_23,kVArh_24,kVArh_25,kVArh_26,kVArh_27,kVArh_28,kVArh_29,kVArh_30,kVArh_31,kVArh_32,kVArh_33,kVArh_34,kVArh_35,kVArh_36,kVArh_37,kVArh_38,kVArh_39,kVArh_40,kVArh_41,kVArh_42,kVArh_43,kVArh_44,kVArh_45,kVArh_46,kVArh_47,kVArh_48
          ABBEY LANE PRIMARY EXTENSION,2380001730739,01/01/2020,5.95500000,2.83220000,2.94080000,2.72960000,1.84320000,0.45760000,1.14880000,1.71200000,1.75680000,1.64160000,2.04480000,3.68640000,4.24640000,0.80960000,0.74560000,1.44320000,1.53280000,1.69600000,1.93920000,2.06720000,2.30080000,2.02240000,3.62240000,4.26240000,1.73120000,1.01760000,0.84800000,1.70880000,0.85120000,0.91520000,2.86080000,2.59200000,2.85120000,2.88640000,2.96640000,6.07000000,1.02440000,2.26880000,3.24800000,3.24800000,3.36640000,3.36960000,2.96960000,2.83200000,2.88320000,4.31040000,5.32450000,2.97950000,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
          ABBEY LANE PRIMARY EXTENSION,2380001730739,02/01/2020,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
          MEERSBROOK PRIMARY - M1,2333300681718,31/12/2019,1.20800000,1.16100000,1.19500000,1.21000000,1.16600000,1.20100000,1.17800000,1.30000000,1.30100000,1.26600000,1.27300000,1.28000000,2.10900000,2.03700000,1.29100000,1.24600000,1.67800000,1.24500000,1.12800000,1.11300000,1.35000000,1.11700000,1.14200000,1.40600000,1.10100000,1.12300000,1.16400000,1.42700000,1.12900000,1.10400000,1.11900000,1.46600000,1.18400000,1.14600000,1.22600000,1.20800000,1.25500000,1.20000000,1.23600000,1.16300000,1.12400000,1.19800000,1.12800000,1.15500000,1.13000000,1.18200000,1.14500000,1.17700000,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
        HEREDOC
      end

      before do
        FileUtils.mkdir_p sheffield_config.local_bucket_path
      end

      it 'does not create records for empty rows (comma, comma)' do
        expect(write_file_and_parse(sheffield_empty_readings, sheffield_config)).to eq 0
        expect(AmrDataFeedImportLog.first.error_messages).to eq AmrReadingData::ERROR_NO_VALID_READINGS
      end

      it 'does not create records for empty rows (comma, comma) but still process file' do
        expect(write_file_and_parse(sheffield_one_empty_reading, sheffield_config)).to eq 2
        expect(AmrDataFeedImportLog.first.records_imported).to eq 2
        expect(AmrReadingWarning.count).to eq 1
      end
    end

    context 'sheffield gas' do
      def example_sheffield_gas
        <<~HEREDOC
          "MPR","Date","hr0030","hr0100","hr0130","hr0200","hr0230","hr0300","hr0330","hr0400","hr0430","hr0500","hr0530","hr0600","hr0630","hr0700","hr0730","hr0800","hr0830","hr0900","hr0930","hr1000","hr1030","hr1100","hr1130","hr1200","hr1230","hr1300","hr1330","hr1400","hr1430","hr1500","hr1530","hr1600","hr1630","hr1700","hr1730","hr1800","hr1830","hr1900","hr1930","hr2000","hr2030","hr2100","hr2130","hr2200","hr2230","hr2300","hr2330","hr0000"
          "6326701","12/09/2017",0.000,0.000,0.000,0.000,0.000,0.000,0.000,0.000,0.000,0.000,0.000,0.000,0.000,0.000,0.000,0.000,0.000,0.000,0.000,0.000,0.000,0.000,0.000,0.000,0.000,0.000,0.000,0.000,0.000,0.000,5.653,16.959,5.653,0.000,0.000,0.000,0.000,0.000,0.000,0.000,0.000,0.000,0.000,0.000,0.000,0.000,0.000,0.000
          "6326701","13/09/2017",0.000,0.000,0.000,0.000,0.000,0.000,0.000,0.000,27.134,4.522,5.653,113.059,124.864,78.743,73.119,69.744,57.370,30.372,19.123,21.373,19.123,10.124,6.749,11.249,11.249,6.749,6.749,11.249,5.625,7.874,0.000,5.625,5.625,4.500,1.125,0.000,0.000,0.000,0.000,0.000,0.000,0.000,0.000,0.000,0.000,0.000,0.000,0.000
        HEREDOC
      end

      before do
        FileUtils.mkdir_p sheffield_gas_config.local_bucket_path
      end

      it 'creates rows for Sheffield gas' do
        expect(write_file_and_parse(example_sheffield_gas, sheffield_gas_config)).to eq 2
      end

      it 'handles a wrong file and creates an error message' do
        FileUtils.mkdir_p frome_config.local_bucket_path
        expect(write_file_and_parse(example_sheffield_gas, frome_config)).to be 0

        expect(AmrDataFeedImportLog.first.error_messages).to eq AmrReadingData::ERROR_NO_VALID_READINGS
      end
    end

    context 'historical frome' do
      def example_frome_historic_shift_one
        <<~HEREDOC
          Site Id,Meter Number,Reading Date,00:00,00:30,01:00,01:30,02:00,02:30,03:00,03:30,04:00,04:30,05:00,05:30,06:00,06:30,07:00,07:30,08:00,08:30,09:00,09:30,10:00,10:30,11:00,11:30,12:00,12:30,13:00,13:30,14:00,14:30,15:00,15:30,16:00,16:30,17:00,17:30,18:00,18:30,19:00,19:30,20:00,20:30,21:00,21:30,22:00,22:30,23:00,23:30
          2000025766288,209458264,25/06/2015,1.8,1.7,1.6,1.5,1.6,1.5,1.5,1.8,1.5,1.6,1.2,1.4,1.7,2.9,3.5,4.9,6.7,6.7,7.4,7.6,6.9,7.1,8.7,9.0,8.2,7.3,6.9,7.2,8.0,8.0,5.1,4.5,4.0,3.3,2.9,2.2,1.6,1.4,1.5,1.6,1.4,1.5,1.6,1.6,1.6,1.6,1.5,1.6
          2000025766288,209458264,26/06/2015,1.7,1.6,1.5,1.5,1.6,1.5,1.9,1.5,1.6,1.5,1.4,1.3,1.4,1.8,2.0,3.0,3.5,2.6,2.6,2.9,3.0,3.3,3.8,3.7,4.3,3.5,3.3,3.7,3.9,4.0,4.3,1.4,1.5,1.6,1.6,1.3,1.3,1.2,1.2,1.2,1.2,1.4,1.5,1.4,1.4,1.8,1.4,1.4
          2000025766288,209458264,27/06/2015,1.5,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0
          2000025766288,209458264,28/06/2015,0.0,1.4,1.5,1.8,1.3,1.5,1.5,1.5,1.5,1.4,1.2,1.1,1.4,1.2,1.2,1.3,1.5,1.2,1.3,1.6,1.9,1.8,1.6,1.8,1.8,1.7,1.8,1.4,1.3,1.3,1.5,1.1,1.2,1.3,1.4,1.3,1.2,1.3,1.2,1.2,1.3,1.7,1.3,1.4,1.7,1.5,1.4,1.5
          2000025766288,209458264,29/06/2015,1.4,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0
          2000025766288,209458264,30/06/2015,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0
          2000025766288,209458264,01/07/2015,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0
          2000025766288,209458264,02/07/2015,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0
          2000025766288,209458264,03/07/2015,0.0,1.6,2.0,1.5,1.8,1.5,1.6,1.6,1.5,1.6,1.4,1.3,1.6,2.2,3.1,4.5,5.5,7.4,7.1,8.4,6.8,7.9,9.0,9.5,9.9,7.6,7.1,7.3,6.7,6.4,4.4,4.5,3.9,3.3,2.9,2.0,1.6,1.3,1.4,1.5,1.8,1.4,1.6,1.7,1.6,1.6,1.6,1.6
        HEREDOC
      end

      before do
        FileUtils.mkdir_p historical_frome_config.local_bucket_path
      end

      it 'handles off by one readings' do
        File.write("#{historical_frome_config.local_bucket_path}/#{file_name}", example_frome_historic_shift_one)
        write_file_and_expect_readings(example_frome_historic_shift_one, historical_frome_config, '1.7', 9)

        results = AmrDataFeedReading.order(:reading_date).all.pluck(:reading_date, :readings).to_h
        expect(results).to eq example_frome_historic_shift_one_expected_output
      end

      def example_frome_historic_shift_one_expected_output
        {
          '01/07/2015' => [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
          '03/07/2015' => [1.6, 2.0, 1.5, 1.8, 1.5, 1.6, 1.6, 1.5, 1.6, 1.4, 1.3, 1.6, 2.2, 3.1, 4.5, 5.5, 7.4, 7.1, 8.4, 6.8, 7.9, 9.0, 9.5, 9.9, 7.6, 7.1, 7.3, 6.7, 6.4, 4.4, 4.5, 3.9, 3.3, 2.9, 2.0, 1.6, 1.3, 1.4, 1.5, 1.8, 1.4, 1.6, 1.7, 1.6, 1.6, 1.6, 1.6, 0.0],
          '02/07/2015' => [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
          '25/06/2015' => [1.7, 1.6, 1.5, 1.6, 1.5, 1.5, 1.8, 1.5, 1.6, 1.2, 1.4, 1.7, 2.9, 3.5, 4.9, 6.7, 6.7, 7.4, 7.6, 6.9, 7.1, 8.7, 9.0, 8.2, 7.3, 6.9, 7.2, 8.0, 8.0, 5.1, 4.5, 4.0, 3.3, 2.9, 2.2, 1.6, 1.4, 1.5, 1.6, 1.4, 1.5, 1.6, 1.6, 1.6, 1.6, 1.5, 1.6, 1.7],
          '26/06/2015' => [1.6, 1.5, 1.5, 1.6, 1.5, 1.9, 1.5, 1.6, 1.5, 1.4, 1.3, 1.4, 1.8, 2.0, 3.0, 3.5, 2.6, 2.6, 2.9, 3.0, 3.3, 3.8, 3.7, 4.3, 3.5, 3.3, 3.7, 3.9, 4.0, 4.3, 1.4, 1.5, 1.6, 1.6, 1.3, 1.3, 1.2, 1.2, 1.2, 1.2, 1.4, 1.5, 1.4, 1.4, 1.8, 1.4, 1.4, 1.5],
          '27/06/2015' => [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
          '28/06/2015' => [1.4, 1.5, 1.8, 1.3, 1.5, 1.5, 1.5, 1.5, 1.4, 1.2, 1.1, 1.4, 1.2, 1.2, 1.3, 1.5, 1.2, 1.3, 1.6, 1.9, 1.8, 1.6, 1.8, 1.8, 1.7, 1.8, 1.4, 1.3, 1.3, 1.5, 1.1, 1.2, 1.3, 1.4, 1.3, 1.2, 1.3, 1.2, 1.2, 1.3, 1.7, 1.3, 1.4, 1.7, 1.5, 1.4, 1.5, 1.4],
          '29/06/2015' => [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
          '30/06/2015' => [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
        }.transform_values { |v| v.map(&:to_s) }
      end
    end

    context 'frome' do
      def frome
        <<~HEREDOC
          10545307,K0229111D6,12/11/18,9.9,4.465528,0.0,3.349146,0.0,4.465528,3.349146,0.0,3.349146,0.0,24.560404,75.913976,41.306134,30.142314,42.422516,37.956988,40.189752,34.607842,41.306134,35.724224,37.956988,34.607842,32.375078,34.607842,39.07337,43.538898,34.607842,42.422516,31.258696,34.607842,26.793168,26.793168,18.978494,1.116382,5.58191,0.0,3.349146,1.116382,0.0,4.465528,0.0,3.349146,0.0,3.349146,4.465528,0.0,3.349146,1.116382
        HEREDOC
      end

      def frome_with_header
        <<~HEREDOC
          Site Id,Meter Number,Reading Date,00:00,00:30,01:00,01:30,02:00,02:30,03:00,03:30,04:00,04:30,05:00,05:30,06:00,06:30,07:00,07:30,08:00,08:30,09:00,09:30,10:00,10:30,11:00,11:30,12:00,12:30,13:00,13:30,14:00,14:30,15:00,15:30,16:00,16:30,17:00,17:30,18:00,18:30,19:00,19:30,20:00,20:30,21:00,21:30,22:00,22:30,23:00,23:30
          10545307,K0229111D6,12/11/18,9.9,4.465528,0.0,3.349146,0.0,4.465528,3.349146,0.0,3.349146,0.0,24.560404,75.913976,41.306134,30.142314,42.422516,37.956988,40.189752,34.607842,41.306134,35.724224,37.956988,34.607842,32.375078,34.607842,39.07337,43.538898,34.607842,42.422516,31.258696,34.607842,26.793168,26.793168,18.978494,1.116382,5.58191,0.0,3.349146,1.116382,0.0,4.465528,0.0,3.349146,0.0,3.349146,4.465528,0.0,3.349146,1.116382
        HEREDOC
      end

      def frome_historic
        <<~HEREDOC
          Site Id,Meter Number,Reading Date,00:00,00:30,01:00,01:30,02:00,02:30,03:00,03:30,04:00,04:30,05:00,05:30,06:00,06:30,07:00,07:30,08:00,08:30,09:00,09:30,10:00,10:30,11:00,11:30,12:00,12:30,13:00,13:30,14:00,14:30,15:00,15:30,16:00,16:30,17:00,17:30,18:00,18:30,19:00,19:30,20:00,20:30,21:00,21:30,22:00,22:30,23:00,23:30
          10545307,K0229111D6,12/11/2018,11.11,4.465528,0.0,3.349146,0.0,4.465528,3.349146,0.0,3.349146,0.0,24.560404,75.913976,41.306134,30.142314,42.422516,37.956988,40.189752,34.607842,41.306134,35.724224,37.956988,34.607842,32.375078,34.607842,39.07337,43.538898,34.607842,42.422516,31.258696,34.607842,26.793168,26.793168,18.978494,1.116382,5.58191,0.0,3.349146,1.116382,0.0,4.465528,0.0,3.349146,0.0,3.349146,4.465528,0.0,3.349146,1.116382
        HEREDOC
      end

      it 'parses a simple file without a header' do
        FileUtils.mkdir_p frome_config.local_bucket_path
        write_file_and_expect_readings(frome, frome_config, '9.9')
      end

      it 'parses a simple file with a header' do
        FileUtils.mkdir_p frome_config.local_bucket_path
        write_file_and_expect_readings(frome_with_header, frome_config, '9.9')
      end

      it 'parses a simple frome historic file with handle off by one (and not move it a long if it is a single row' do
        FileUtils.mkdir_p historical_frome_config.local_bucket_path
        write_file_and_expect_readings(frome_historic, historical_frome_config, '11.11')
      end
    end

    context 'banes' do
      def banes
        <<~HEREDOC
          ID,Date,Location,Type,PostCode,Units,Total Units,[00:30],[01:00],[01:30],[02:00],[02:30],[03:00],[03:30],[04:00],[04:30],[05:00],[05:30],[06:00],[06:30],[07:00],[07:30],[08:00],[08:30],[09:00],[09:30],[10:00],[10:30],[11:00],[11:30],[12:00],[12:30],[13:00],[13:30],[14:00],[14:30],[15:00],[15:30],[16:00],[16:30],[17:00],[17:30],[18:00],[18:30],[19:00],[19:30],[20:00],[20:30],[21:00],[21:30],[22:00],[22:30],[23:00],[23:30],[24:00],M1_Code1,M1_Code2
          "59d21d2b33942ec3d1106ed2126c6b6b","Sep  3 2018 12:00AM","High Littleton C of E Primary School (Academy)","Electricity","BS39 6HF","kWh","24.871","0.165","0.183","0.062","0.068","0.067","0.063","0.093","0.117","0.43","0.068","0.074","0.321","0.929","0.759","0.928","0.7","0.728","0.723","1.051","0.885","0.828","1.048","0.823","0.969","1.098","0.869","0.909","0.952","1.187","0.907","1.092","1.325","0.913","0.853","0.269","0.254","0.274","0.156","0.151","0.448","0.134","0.122","0.243","0.122","0.122","0.116","0.122","0.151","2200012030347","E10BG50326"

          (3794 rows affected)
        HEREDOC
      end

      def banes_duff
        <<~HEREDOC
          ID,Date,Location,Type,PostCode,Units,Total Units,[00:30],[01:00],[01:30],[02:00],[02:30],[03:00],[03:30],[04:00],[04:30],[05:00],[05:30],[06:00],[06:30],[07:00],[07:30],[08:00],[08:30],[09:00],[09:30],[10:00],[10:30],[11:00],[11:30],[12:00],[12:30],[13:00],[13:30],[14:00],[14:30],[15:00],[15:30],[16:00],[16:30],[17:00],[17:30],[18:00],[18:30],[19:00],[19:30],[20:00],[20:30],[21:00],[21:30],[22:00],[22:30],[23:00],[23:30],[24:00],M1_Code1,M1_Code2
          "59d21d2b33942ec3d1106ed2126c6b6b","Sep  3 2018 12:00AM","High Littleton C of E Primary School (Academy)","Electricity","BS39 6HF","kWh","24.871","0.165","0.183","0.062","0.068","0.067","0.063","0.093","0.117","0.43","0.068","0.074","0.321","0.929","0.759","0.928","0.7","0.728","0.723","1.051","0.885","0.828","1.048","0.823","0.969","1.098","0.869","0.909","0.952","1.187","0.907","1.092","1.325","0.913","0.853","0.269","0.254","0.274","0.156","0.151","0.448","0.134","0.122","0.243","0.122","0.122","0.116","0.122","0.151","2200012030347","E10BG50326"
          "59d21d2b33942ec3d1106ed2126c6b6b","Sep  3 2018
          "59d21d2b33942ec3d1106ed2126c6b6b","Sep  3 2018 12:00AM","High Littleton C of E Primary School (Academy)","Electricity","BS39 6HF","kWh","24.871","0.165","0.183","0.062","0.068","0.067","0.063","0.093","0.117","0.43","0.068","0.074","0.321","0.929","0.759","0.928","0.7","0.728","0.723","1.051","0.885","0.828","1.048","0.823","0.969","1.098","0.869","0.909","0.952","1.187","0.907","1.092","1.325","0.913","0.853","0.269","0.254","0.274","0.156","0.151","0.448","0.134","0.122","0.243","0.122","0.122","0.116","0.122","0.151","2200012030348","E10BG50326"
          "59d21d2b33942ec3d1106ed2126c6b6b","Sep  3 2018 12:00AM","High Littleton C of E Primary School (Academy)","Electricity","BS39 6HF","kWh","24.871","0.165","0.183","0.062","0.068","0.067","0.063","0.093","0.117","0.43","0.068","0.074","0.321","0.929","0.759","0.928","0.7","0.728","0.723","1.051","0.885","0.828","1.048","0.823","0.969","1.098","0.869","0.909","0.952","1.187","0.907","1.092","1.325","0.913","0.853","0.269","0.254","0.274","0.156","0.151","0.448","0.134","0.122","0.243","0.122","0.122","0.116","0.122","0.151","2200012030349","E10BG50326"
        HEREDOC
      end

      def banes_duplicate_rows
        <<~HEREDOC
          ID,Date,Location,Type,PostCode,Units,Total Units,[00:30],[01:00],[01:30],[02:00],[02:30],[03:00],[03:30],[04:00],[04:30],[05:00],[05:30],[06:00],[06:30],[07:00],[07:30],[08:00],[08:30],[09:00],[09:30],[10:00],[10:30],[11:00],[11:30],[12:00],[12:30],[13:00],[13:30],[14:00],[14:30],[15:00],[15:30],[16:00],[16:30],[17:00],[17:30],[18:00],[18:30],[19:00],[19:30],[20:00],[20:30],[21:00],[21:30],[22:00],[22:30],[23:00],[23:30],[24:00],M1_Code1,M1_Code2
          "59d21d2b33942ec3d1106ed2126c6b6b","Sep  3 2018 12:00AM","High Littleton C of E Primary School (Academy)","Electricity","BS39 6HF","kWh","24.871","0.165","0.183","0.062","0.068","0.067","0.063","0.093","0.117","0.43","0.068","0.074","0.321","0.929","0.759","0.928","0.7","0.728","0.723","1.051","0.885","0.828","1.048","0.823","0.969","1.098","0.869","0.909","0.952","1.187","0.907","1.092","1.325","0.913","0.853","0.269","0.254","0.274","0.156","0.151","0.448","0.134","0.122","0.243","0.122","0.122","0.116","0.122","0.151","2200012030347","E10BG50326"
          "59d21d2b33942ec3d1106ed2126c6b6b","Sep  3 2018 12:00AM","High Littleton C of E Primary School (Academy)","Electricity","BS39 6HF","kWh","24.871","0.165","0.183","0.062","0.068","0.067","0.063","0.093","0.117","0.43","0.068","0.074","0.321","0.929","0.759","0.928","0.7","0.728","0.723","1.051","0.885","0.828","1.048","0.823","0.969","1.098","0.869","0.909","0.952","1.187","0.907","1.092","1.325","0.913","0.853","0.269","0.254","0.274","0.156","0.151","0.448","0.134","0.122","0.243","0.122","0.122","0.116","0.122","0.151","2200012030347","E10BG50326"
          (3794 rows affected)
        HEREDOC
      end

      def banes_no_header
        <<~HEREDOC
          "59d21d2b33942ec3d1106ed2126c6b6b","Sep  3 2018 12:00AM","High Littleton C of E Primary School (Academy)","Electricity","BS39 6HF","kWh","24.871","0.165","0.183","0.062","0.068","0.067","0.063","0.093","0.117","0.43","0.068","0.074","0.321","0.929","0.759","0.928","0.7","0.728","0.723","1.051","0.885","0.828","1.048","0.823","0.969","1.098","0.869","0.909","0.952","1.187","0.907","1.092","1.325","0.913","0.853","0.269","0.254","0.274","0.156","0.151","0.448","0.134","0.122","0.243","0.122","0.122","0.116","0.122","0.151","2200012030347","E10BG50326"

          (3794 rows affected)
        HEREDOC
      end

      # Different total and first reading
      def banes_upsert
        <<~HEREDOC
          ID,Date,Location,Type,PostCode,Units,Total Units,[00:30],[01:00],[01:30],[02:00],[02:30],[03:00],[03:30],[04:00],[04:30],[05:00],[05:30],[06:00],[06:30],[07:00],[07:30],[08:00],[08:30],[09:00],[09:30],[10:00],[10:30],[11:00],[11:30],[12:00],[12:30],[13:00],[13:30],[14:00],[14:30],[15:00],[15:30],[16:00],[16:30],[17:00],[17:30],[18:00],[18:30],[19:00],[19:30],[20:00],[20:30],[21:00],[21:30],[22:00],[22:30],[23:00],[23:30],[24:00],M1_Code1,M1_Code2
          "59d21d2b33942ec3d1106ed2126c6b6b","Sep  3 2018 12:00AM","High Littleton C of E Primary School (Academy)","Electricity","BS39 6HF","kWh","24.872","0.166","0.183","0.062","0.068","0.067","0.063","0.093","0.117","0.43","0.068","0.074","0.321","0.929","0.759","0.928","0.7","0.728","0.723","1.051","0.885","0.828","1.048","0.823","0.969","1.098","0.869","0.909","0.952","1.187","0.907","1.092","1.325","0.913","0.853","0.269","0.254","0.274","0.156","0.151","0.448","0.134","0.122","0.243","0.122","0.122","0.116","0.122","0.151","2200012030347","E10BG50326"
        HEREDOC
      end

      def banes_empty_readings
        <<~HEREDOC
          ID,Date,Location,Type,PostCode,Units,Total Units,[00:30],[01:00],[01:30],[02:00],[02:30],[03:00],[03:30],[04:00],[04:30],[05:00],[05:30],[06:00],[06:30],[07:00],[07:30],[08:00],[08:30],[09:00],[09:30],[10:00],[10:30],[11:00],[11:30],[12:00],[12:30],[13:00],[13:30],[14:00],[14:30],[15:00],[15:30],[16:00],[16:30],[17:00],[17:30],[18:00],[18:30],[19:00],[19:30],[20:00],[20:30],[21:00],[21:30],[22:00],[22:30],[23:00],[23:30],[24:00],M1_Code1,M1_Code2
          "59d21d2b33942ec3d1106ed2126c6b6b","Sep  3 2018 12:00AM","High Littleton C of E Primary School (Academy)","Electricity","BS39 6HF","kWh","24.871","0.165","0.183","0.062","0.068","0.067","0.063","0.093","0.117","0.43","0.068","0.074","0.321","0.929","0.759","0.928","0.7","0.728","0.723","1.051","0.885","0.828","1.048","0.823","0.969","1.098","0.869","0.909","0.952","1.187","0.907","1.092","1.325","0.913","0.853","0.269","0.254","0.274","0.156","0.151","0.448","0.134","0.122","0.243","0.122","0.122","0.116","0.122","0.151","2200012030347","E10BG50326"
          "59d21d2b33942ec3d1106ed2126c6b6b","Sep  4 2018 12:00AM","High Littleton C of E Primary School (Academy)","Electricity","BS39 6HF","kWh","24.871","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","2200012030347","E10BG50326"
          "59d21d2b33942ec3d1106ed2126c6b6b","Sep  5 2018 12:00AM","High Littleton C of E Primary School (Academy)","Electricity","BS39 6HF","kWh","24.871","0.165","0.183","0.062","0.068","0.067","0.063","0.093","0.117","0.43","0.068","0.074","0.321","0.929","0.759","0.928","0.7","0.728","0.723","1.051","0.885","0.828","1.048","0.823","0.969","1.098","0.869","0.909","0.952","1.187","0.907","1.092","1.325","0.913","0.853","0.269","0.254","0.274","0.156","0.151","0.448","0.134","0.122","0.243","0.122","0.122","0.116","0.122","0.151","2200012030347","E10BG50326"
          (3794 rows affected)
        HEREDOC
      end

      def banes_truncated_row
        <<~HEREDOC
          ID,Date,Location,Type,PostCode,Units,Total Units,[00:30],[01:00],[01:30],[02:00],[02:30],[03:00],[03:30],[04:00],[04:30],[05:00],[05:30],[06:00],[06:30],[07:00],[07:30],[08:00],[08:30],[09:00],[09:30],[10:00],[10:30],[11:00],[11:30],[12:00],[12:30],[13:00],[13:30],[14:00],[14:30],[15:00],[15:30],[16:00],[16:30],[17:00],[17:30],[18:00],[18:30],[19:00],[19:30],[20:00],[20:30],[21:00],[21:30],[22:00],[22:30],[23:00],[23:30],[24:00],M1_Code1,M1_Code2
          "59d21d2b33942ec3d1106ed2126c6b6b","Sep  3 2018 12:00AM","High Littleton C of E Primary School (Academy)","Electricity","BS39 6HF","kWh","24.871","0.165","0.183","0.062","0.068","0.067","0.063","0.093","0.117","0.43","0.068","0.074","0.321","0.929","0.759","0.928","0.7","0.728","0.723","1.051","0.885","0.828","1.048","0.823","0.969","1.098","0.869","0.909","0.952","1.187","0.907","1.092","1.325","0.913","0.853","0.269","0.254","0.274","0.156","0.151","0.448","0.134","0.122","0.243","0.122","0.122","0.116","0.122","0.151","2200012030347","E10BG50326"
          "59d21d2b33942ec3d1106ed2126c6b6b","Sep  4 2018 12:00AM","High Littleton C of E Primary School (Academy)","Electricity","BS39 6HF","kWh","24.871","0.165","0.183","0.062","0.068","0.067","0.063","0.093","0.117","0.43","0.068","0.074","0.321","0.929","0.759","0.928","0.7","0.728","0.723","1.051","0.885","0.828","1.048","0.823","0.969","1.098","0.869","0.909","0.952","1.187","0.907","1.092","1.325","0.913","0.853","0.269","0.254","0.274","0.156","0.151","0.448","0.134","0.122","0.243","0.122","0.122","0.116","0.122","0.151","2200012030347","E10BG50326"
          "59d21d2b33942ec3d1106ed2126c6b6b","Sep  5 2018 12:00AM","High Littleton C of E Primary School (Academy)","Electricity","BS39 6HF","kWh","24.871","0.165"

          (3794 rows affected)
        HEREDOC
      end

      def banes_truncated_middle
        <<~HEREDOC
          ID,Date,Location,Type,PostCode,Units,Total Units,[00:30],[01:00],[01:30],[02:00],[02:30],[03:00],[03:30],[04:00],[04:30],[05:00],[05:30],[06:00],[06:30],[07:00],[07:30],[08:00],[08:30],[09:00],[09:30],[10:00],[10:30],[11:00],[11:30],[12:00],[12:30],[13:00],[13:30],[14:00],[14:30],[15:00],[15:30],[16:00],[16:30],[17:00],[17:30],[18:00],[18:30],[19:00],[19:30],[20:00],[20:30],[21:00],[21:30],[22:00],[22:30],[23:00],[23:30],[24:00],M1_Code1,M1_Code2
          "59d21d2b33942ec3d1106ed2126c6b6b","Sep  3 2018 12:00AM","High Littleton C of E Primary School (Academy)","Electricity","BS39 6HF","kWh","24.871","0.165","0.183","0.062","0.068","0.067","0.063","0.093","0.117","0.43","0.068","0.074","0.321","0.929","0.759","0.928","0.7","0.728","0.723","1.051","0.885","0.828","1.048","0.823","0.969","1.098","0.869","0.909","0.952","1.187","0.907","1.092","1.325","0.913","0.853","0.269","0.254","0.274","0.156","0.151","0.448","0.134","0.122","0.243","0.122","0.122","0.116","0.122","0.151","2200012030347","E10BG50326"
          "59d21d2b33942ec3d1106ed2126c6b6b","Sep  4 2018"
          "59d21d2b33942ec3d1106ed2126c6b6b","Sep  5 2018 12:00AM","High Littleton C of E Primary School (Academy)","Electricity","BS39 6HF","kWh","24.871","0.165","0.183","0.062","0.068","0.067","0.063","0.093","0.117","0.43","0.068","0.074","0.321","0.929","0.759","0.928","0.7","0.728","0.723","1.051","0.885","0.828","1.048","0.823","0.969","1.098","0.869","0.909","0.952","1.187","0.907","1.092","1.325","0.913","0.853","0.269","0.254","0.274","0.156","0.151","0.448","0.134","0.122","0.243","0.122","0.122","0.116","0.122","0.151","2200012030348","E10BG50326"
          "59d21d2b33942ec3d1106ed2126c6b6b","Sep  6 2018 12:00AM","High Littleton C of E Primary School (Academy)","Electricity","BS39 6HF","kWh","24.871","0.165","0.183","0.062","0.068","0.067","0.063","0.093","0.117","0.43","0.068","0.074","0.321","0.929","0.759","0.928","0.7","0.728","0.723","1.051","0.885","0.828","1.048","0.823","0.969","1.098","0.869","0.909","0.952","1.187","0.907","1.092","1.325","0.913","0.853","0.269","0.254","0.274","0.156","0.151","0.448","0.134","0.122","0.243","0.122","0.122","0.116","0.122","0.151","2200012030349","E10BG50326"
        HEREDOC
      end

      before do
        FileUtils.mkdir_p config.local_bucket_path
      end

      it 'creates warnings for when final row is truncated' do
        write_file_and_parse(banes_truncated_row, config)

        expect(AmrDataFeedReading.count).to be 2
        expect(AmrDataFeedImportLog.count).to be 1
        expect(AmrReadingWarning.count).to be 1
      end

      it 'creates warnings for truncated row' do
        write_file_and_parse(banes_truncated_middle, config)

        expect(AmrDataFeedReading.count).to be 3
        expect(AmrDataFeedImportLog.count).to be 1
        expect(AmrReadingWarning.count).to be 1
      end

      it 'handles banes format' do
        write_file_and_expect_readings(banes, config)
      end

      it 'handles duplicate records cleanly' do
        write_file_and_expect_readings(banes_duplicate_rows, config)
      end

      it 'handles no header if config set' do
        config.update(number_of_header_rows: 0)
        write_file_and_expect_readings(banes_no_header, config)
      end

      it 'handles graceful failure' do
        expect { write_file_and_parse(banes_duff, config) }.to raise_error(Amr::DataFileParser::Error)

        expect(AmrDataFeedReading.count).to be 0
        expect(AmrDataFeedImportLog.count).to be 1
        expect(AmrDataFeedImportLog.first.records_imported).to be nil
      end

      it 'upserts if appropriate' do
        write_file_and_expect_readings(banes, config)
        write_file_and_expect_updated_readings(banes_upsert, config)
        expect(AmrDataFeedReading.first.readings.first).to eq '0.166'
      end

      it 'creates warnings of blank rows' do
        write_file_and_parse(banes_empty_readings, config)

        expect(AmrDataFeedReading.count).to be 2
        expect(AmrDataFeedImportLog.count).to be 1
        expect(AmrReadingWarning.count).to be 1
      end
    end

    context 'solar for schools' do
      def solar_for_schools_with_header
        <<~HEREDOC
          id,name,date,type,MPAN,12:00 AM,12:30 AM,1:00 AM,1:30 AM,2:00 AM,2:30 AM,3:00 AM,3:30 AM,4:00 AM,4:30 AM,5:00 AM,5:30 AM,6:00 AM,6:30 AM,7:00 AM,7:30 AM,8:00 AM,8:30 AM,9:00 AM,9:30 AM,10:00 AM,10:30 AM,11:00 AM,11:30 AM,12:00 PM,12:30 PM,1:00 PM,1:30 PM,2:00 PM,2:30 PM,3:00 PM,3:30 PM,4:00 PM,4:30 PM,5:00 PM,5:30 PM,6:00 PM,6:30 PM,7:00 PM,7:30 PM,8:00 PM,8:30 PM,9:00 PM,9:30 PM,10:00 PM,10:30 PM,11:00 PM,11:30 PM
          225,Kingfisher Hall Primary Academy,01 09 2016,C,91030083649169,5.616,6.696,6.66,6.276,6.408,6.732,6.444,6.048,6.24,5.952,6.132,6.384,5.568,6.564,6.876,6.816,7.008,9.144,17.16,16.596,17.916,17.172,13.296,14.28,13.704,10.14,6.348,5.412,6.408,6.768,6.588,6.132,6.864,5.952,5.964,6.132,5.94,6.048,6.66,6.36,6.852,6.696,6.576,5.904,6.444,6.804,6.168,6.264
        HEREDOC
      end

      it 'parses a simple file with a header' do
        FileUtils.mkdir_p solar_for_schools_config.local_bucket_path
        write_file_and_expect_readings(solar_for_schools_with_header, solar_for_schools_config, '5.616')
      end
    end
  end
end
