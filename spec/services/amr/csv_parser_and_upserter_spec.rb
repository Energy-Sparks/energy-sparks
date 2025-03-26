require 'rails_helper'

describe Amr::CsvParserAndUpserter do
  def perform
    described_class.perform(config, "spec/fixtures/amr_data/#{config.identifier}/#{file_name}", file_name)
  end

  let(:import_log) { perform }

  shared_examples 'it updates the database' do
    it 'inserts correct number of records' do
      expect(import_log.records_imported).to eq inserted
      expect(AmrDataFeedReading.count).to eq(inserted + updated)
    end

    it 'updates the correct number of records' do
      expect(import_log.records_updated).to eq updated
    end

    it 'records a log' do
      expect(AmrDataFeedImportLog.count).to eq 1
    end
  end

  shared_examples 'it successfully processes the file' do
    let(:inserted) { 1 }
    let(:updated) { 0 }

    before do
      import_log
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
      import_log
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
      import_log
    end

    it 'does not update the database' do
      expect(import_log.records_imported).to eq 0
      expect(import_log.records_updated).to eq 0
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

  shared_examples 'it handles empty files' do
    context 'with empty file' do
      let(:file_name) { 'empty.csv' }

      it_behaves_like 'it rejects the file'
    end

    context 'with Microsoft Excel annotation' do
      let(:file_name) { 'empty-msft.csv' }

      it_behaves_like 'it rejects the file'
    end

    context 'with a header' do
      let(:file_name) { 'empty-with-header.csv' }

      it_behaves_like 'it rejects the file'
    end
  end

  context 'with row per day files' do
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

    it_behaves_like 'it handles empty files'

    context 'with valid file' do
      let(:file_name) { 'valid.csv' }

      it_behaves_like 'it successfully processes the file'

      context 'when reloaded' do
        it 'upserts the data' do
          expect(import_log.records_imported).to eq 1
          expect(import_log.records_updated).to eq 0

          import_log = perform
          expect(import_log.records_imported).to eq 0
          expect(import_log.records_updated).to eq 1
        end
      end
    end

    context 'with valid file and no header expected' do
      let(:file_name) { 'valid-no-header.csv' }

      before do
        config.update!(number_of_header_rows: 0)
      end

      it_behaves_like 'it successfully processes the file'
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
        expect { import_log }.to raise_error(Amr::DataFileParser::Error)
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

  context 'with row per reading files' do
    let!(:config) do
      create(:amr_data_feed_config,
        identifier: 'row-per-reading',
        row_per_reading: true,
        half_hourly_labelling: :end,
        number_of_header_rows: 2,
        date_format: '%e %b %Y %H:%M:%S',
        mpan_mprn_field: 'MPR',
        reading_date_field: 'ReadDatetime',
        reading_fields: ['kWh'],
        header_example: 'MPR,ReadDatetime,kWh,ReadType'
      )
    end

    it_behaves_like 'it handles empty files'

    context 'with valid file' do
      let(:file_name) { 'valid.csv' }

      it_behaves_like 'it successfully processes the file'

      it 'does not have any blank readings' do
        import_log
        AmrDataFeedReading.all.find_each do |reading_record|
          expect(reading_record.readings.any?(&:blank?)).to be false
        end
      end
    end

    context 'with partially valid files' do
      context 'when missing readings for some rows' do
        let(:file_name) { 'some-missing-readings.csv' }

        # no warnings here as filtered by SingleReadConverter
        # due to missing readings limit
        it_behaves_like 'it successfully processes the file' do
          let(:inserted) { 1 }
        end

        context 'with increased missing readings limit' do
          before do
            config.update!(missing_readings_limit: 10)
          end

          it_behaves_like 'it successfully processes the file' do
            let(:inserted) { 2 }
          end
        end

        context 'when set to merge' do
          before do
            config.update!(allow_merging: true, half_hourly_labelling: :start)
          end

          it_behaves_like 'it successfully processes the file' do
            let(:inserted) { 2 }
          end
        end
      end
    end
  end
end
