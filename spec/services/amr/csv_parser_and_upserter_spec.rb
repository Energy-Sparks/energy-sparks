require 'rails_helper'
require 'fileutils'

describe Amr::CsvParserAndUpserter do
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

  # row per reading, valid
  # row per reading, shifted?
  context 'highlands with real files' do
    it 'imports a csv' do
      ClimateControl.modify AMR_CONFIG_LOCAL_FILE_BUCKET_PATH: 'spec/fixtures' do
        expect(AmrDataFeedReading.count).to be 0
        importer = described_class.new(highlands_config, 'example.csv')
        importer.perform

        AmrDataFeedReading.all.find_each do |reading_record|
          expect(reading_record.readings.any?(&:blank?)).to be false
        end

        expect(AmrDataFeedReading.count).to be 10
        expect(importer.inserted_record_count).to be 10
      end
    end

    it 'imports a csv where the times are shifted by half an hour' do
      ClimateControl.modify AMR_CONFIG_LOCAL_FILE_BUCKET_PATH: 'spec/fixtures' do
        expect(AmrDataFeedReading.count).to be 0
        importer = described_class.new(highlands_config, 'example-offset.csv')
        importer.perform

        AmrDataFeedReading.all.find_each do |reading_record|
          expect(reading_record.readings.count(&:blank?)).to be <= highlands_config.blank_threshold
        end

        expect(AmrDataFeedReading.count).to be 7
        expect(importer.inserted_record_count).to be 7
      end
    end

    it 'record exception when file is truncated' do
      ClimateControl.modify AMR_CONFIG_LOCAL_FILE_BUCKET_PATH: 'spec/fixtures' do
        expect(AmrDataFeedReading.count).to be 0
        importer = described_class.new(highlands_config, 'empty.csv')
        importer.perform

        expect(AmrDataFeedReading.count).to be 0
        expect(importer.inserted_record_count).to be 0
        expect(AmrDataFeedImportLog.last.error_messages).not_to be_nil
      end
    end

    it 'record exception when file is invalid' do
      ClimateControl.modify AMR_CONFIG_LOCAL_FILE_BUCKET_PATH: 'spec/fixtures' do
        expect(AmrDataFeedReading.count).to be 0

        e = StandardError.new
        expect_any_instance_of(Amr::DataFileToAmrReadingData).to receive(:perform).and_raise(e)

        importer = described_class.new(highlands_config, 'empty.csv')
        expect { importer.perform }.to raise_error StandardError

        expect(AmrDataFeedReading.count).to be 0
        expect(importer.inserted_record_count).to be 0
      end
    end
  end

  shared_examples 'it updates the database' do
    it 'inserts correct number of records' do
      expect(service.inserted_record_count).to eq inserted
      expect(AmrDataFeedReading.count).to eq(inserted + updated)
    end

    it 'updates the correct number of records' do
      expect(service.upserted_record_count).to eq updated
    end

    it 'records a log' do
      expect(AmrDataFeedImportLog.count).to eq 1
    end
  end

  shared_examples 'it successfully processes the file' do
    let(:inserted) { 1 }
    let(:updated) { 0 }

    before do
      service.perform
    end

    it_behaves_like 'it updates the database'

    it 'does not log errors' do
      expect(AmrDataFeedImportLog.last.error_messages).to be_nil
    end

    it 'does not log warnings' do
      expect(AmrReadingWarning.count).to eq 0
    end
  end

  shared_examples 'it successfully processes the file, with warnings' do
    let(:inserted) { 1 }
    let(:updated) { 0 }
    let(:warnings) { 1 }
    let(:warning_type) { :missing_readings }

    before do
      service.perform
    end

    it_behaves_like 'it updates the database'

    it 'does not log errors' do
      expect(AmrDataFeedImportLog.last.error_messages).to be_nil
    end

    it 'logs expected warnings' do
      expect(AmrReadingWarning.count).to eq warnings
      # we store multiple warning types for each warning as an array
      warning_types = [AmrReadingWarning::WARNINGS.key(warning_type)]
      expect(AmrReadingWarning.first.warning_types).to match_array(warning_types)
    end
  end

  shared_examples 'it rejects the file' do
    before do
      service.perform
    end

    it 'does not update the database' do
      expect(service.inserted_record_count).to eq 0
      expect(service.upserted_record_count).to eq 0
      expect(AmrDataFeedReading.count).to eq 0
    end

    it 'records a log' do
      expect(AmrDataFeedImportLog.count).to eq 1
    end

    it 'does logs errors' do
      expect(AmrDataFeedImportLog.last.error_messages).not_to be_nil
    end

    it 'does not log warnings' do
      expect(AmrReadingWarning.count).to eq 0
    end
  end

  context 'with row per day files' do
    subject(:service) { described_class.new(config, file_name) }

    let(:valid_reading_times) do
      48.times.map do |hh|
        TimeOfDay.time_of_day_from_halfhour_index(hh).to_s
      end
    end

    let!(:config) do
      create(:amr_data_feed_config,
        identifier: 'row-per-day',
        number_of_header_rows: 1,
        date_format: '%d/%m/%y',
        mpan_mprn_field: 'Site Id',
        msn_field: 'Meter Number',
        reading_date_field: 'Reading Date',
        reading_fields: valid_reading_times,
        header_example: 'Site Id,Meter Number,Reading Date,' + valid_reading_times.join(',')
      )
    end

    around do |example|
      FakeFS.deactivate!
      ClimateControl.modify AMR_CONFIG_LOCAL_FILE_BUCKET_PATH: 'spec/fixtures/amr_data' do
        example.run
      end
      # FakeFS.activate!
    end

    context 'with valid file' do
      let(:file_name) { 'valid.csv' }

      it_behaves_like 'it successfully processes the file'
    end

    context 'with valid file and no header expected' do
      let(:file_name) { 'valid-no-header.csv' }

      before do
        config.update!(number_of_header_rows: 0)
      end

      it_behaves_like 'it successfully processes the file'
    end

    context 'with empty files' do
      let(:file_name) { 'empty.csv' }

      it_behaves_like 'it rejects the file'

      context 'with Microsoft Excel annotation' do
        let(:file_name) { 'empty-msft.csv' }

        it_behaves_like 'it rejects the file'
      end

      context 'with a header' do
        let(:file_name) { 'empty-with-header.csv' }

        it_behaves_like 'it rejects the file'
      end
    end

    context 'with file with problems for all rows' do
      context 'when there are partial readings' do
        let(:file_name) { 'all-missing-readings.csv' }

        it_behaves_like 'it rejects the file'
      end

      context 'when the readings are blank' do
        let(:file_name) { 'no-readings.csv' }

        it_behaves_like 'it rejects the file'
      end

      context 'when the rows are incomplete' do
        let(:file_name) { 'incomplete-row.csv' }

        it_behaves_like 'it rejects the file'
      end
    end

    context 'with malformed csv file' do
      let(:file_name) { 'malformed.csv' }

      it 'throws an exception' do
        expect { service.perform }.to raise_error(Amr::DataFileParser::Error)
      end
    end

    context 'with partially valid files' do
      context 'when missing readings for some rows' do
        let(:file_name) { 'some-missing-readings.csv' }

        it_behaves_like 'it successfully processes the file, with warnings' do
          let(:inserted) { 2 }
        end
      end

      context 'when there are duplicate rows' do
        let(:file_name) { 'duplicate-rows.csv' }

        it_behaves_like 'it successfully processes the file, with warnings' do
          let(:inserted) { 1 }
          let(:warning_type) { :duplicate_reading }
        end
      end
    end

    context 'with incorrectly formatted file' do
      let!(:config) do
        create(:amr_data_feed_config,
          identifier: 'row-per-day',
          number_of_header_rows: 1,
          date_format: '%d/%m/%y',
          mpan_mprn_field: 'MPAN',
          reading_date_field: 'Date',
          reading_fields: valid_reading_times,
          header_example: 'MPAN,Reading Date,' + valid_reading_times.join(',')
        )
      end

      let(:file_name) { 'valid.csv' }

      it_behaves_like 'it rejects the file'
    end
  end
end
