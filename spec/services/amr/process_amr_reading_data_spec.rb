require 'rails_helper'

module Amr
  describe ProcessAmrReadingData do

    let!(:amr_data_feed_import_log) { create(:amr_data_feed_import_log) }
    let(:reading_data_first)        { { :mpan_mprn => 123, :reading_date => Date.parse('2019-01-01'), readings: Array.new(48, '0.0'), amr_data_feed_config_id: amr_data_feed_import_log.amr_data_feed_config_id } }
    let(:reading_data_second)       { { :mpan_mprn => 123, :reading_date => Date.parse('2019-01-02'), readings: Array.new(48, '0.0'), amr_data_feed_config_id: amr_data_feed_import_log.amr_data_feed_config_id } }
    let(:reading_data_third)        { { :mpan_mprn => 123, :reading_date => Date.parse('2019-01-03'), readings: Array.new(48, '0.0'), amr_data_feed_config_id: amr_data_feed_import_log.amr_data_feed_config_id } }
    let(:reading_data)              { [ reading_data_first, reading_data_second, reading_data_third ] }

    let(:amr_reading)               { AmrReadingData.new(reading_data: reading_data, date_format:  '%Y-%m-%d') }

    it 'processes a valid amr reading data' do
      expect { ProcessAmrReadingData.new(amr_reading, amr_data_feed_import_log).perform }.to change { AmrDataFeedReading.count }.by(3)
      expect(amr_data_feed_import_log.error_messages).to be_blank
      expect(amr_data_feed_import_log.amr_reading_warnings).to be_empty
    end

    describe 'creates a warning if required' do
      it 'handles missing mpan mprn' do
        reading_data_second[:mpan_mprn] = nil
        expect { ProcessAmrReadingData.new(amr_reading, amr_data_feed_import_log).perform }.to change { AmrDataFeedReading.count }.by(2).and change { AmrReadingWarning.count }.by(1)

        first_warning = AmrReadingWarning.first
        expect(first_warning.warning.to_sym).to be :missing_mpan_mprn
        expect(first_warning.warning_message).to eq AmrReadingData::WARNINGS[:missing_mpan_mprn]
        expect(first_warning.readings).to match_array reading_data_second[:readings]
        expect(first_warning.reading_date).to eq reading_data_second[:reading_date].to_s
      end

      it 'handles blank readings' do
        reading_data_second[:readings] = Array.new(48, nil)
        expect { ProcessAmrReadingData.new(amr_reading, amr_data_feed_import_log).perform }.to change { AmrDataFeedReading.count }.by(2).and change { AmrReadingWarning.count }.by(1)

        first_warning = AmrReadingWarning.first
        expect(first_warning.warning.to_sym).to be :missing_readings
        expect(first_warning.warning_message).to eq AmrReadingData::WARNINGS[:missing_readings]
        expect(first_warning.readings).to match_array reading_data_second[:readings]
        expect(first_warning.reading_date).to eq reading_data_second[:reading_date].to_s
      end

      it 'handles missing readings' do
        reading_data_second[:readings] = Array.new(4, '0.0')
        expect { ProcessAmrReadingData.new(amr_reading, amr_data_feed_import_log).perform }.to change { AmrDataFeedReading.count }.by(2).and change { AmrReadingWarning.count }.by(1)

        first_warning = AmrReadingWarning.first
        expect(first_warning.warning.to_sym).to be :missing_readings
        expect(first_warning.warning_message).to eq AmrReadingData::WARNINGS[:missing_readings]
        expect(first_warning.readings).to match_array reading_data_second[:readings]
        expect(first_warning.reading_date).to eq reading_data_second[:reading_date].to_s
      end

      it 'handles missing readings' do
        reading_data_second[:reading_date] = nil
        expect { ProcessAmrReadingData.new(amr_reading, amr_data_feed_import_log).perform }.to change { AmrDataFeedReading.count }.by(2).and change { AmrReadingWarning.count }.by(1)

        first_warning = AmrReadingWarning.first
        expect(first_warning.warning.to_sym).to be :missing_reading_date
        expect(first_warning.warning_message).to eq AmrReadingData::WARNINGS[:missing_reading_date]
        expect(first_warning.readings).to match_array reading_data_second[:readings]
        expect(first_warning.reading_date).to be_nil
      end

      it 'handles invalid reading date' do
        reading_data_second[:reading_date] = 'WOOF'
        expect { ProcessAmrReadingData.new(amr_reading, amr_data_feed_import_log).perform }.to change { AmrDataFeedReading.count }.by(2).and change { AmrReadingWarning.count }.by(1)

        first_warning = AmrReadingWarning.first
        expect(first_warning.warning.to_sym).to be :invalid_reading_date
        expect(first_warning.warning_message).to eq AmrReadingData::WARNINGS[:invalid_reading_date]
        expect(first_warning.readings).to match_array reading_data_second[:readings]
        expect(first_warning.reading_date).to eq reading_data_second[:reading_date].to_s
      end

      it 'creates an error on the import log if no records could be imported' do
        reading_data_first[:reading_date] = 'MEOW'
        reading_data_second[:reading_date] = 'WOOF'
        reading_data_third[:reading_date] = 'QUACK'
        expect { ProcessAmrReadingData.new(amr_reading, amr_data_feed_import_log).perform }.to change { AmrDataFeedReading.count }.by(0).and change { AmrReadingWarning.count }.by(3)

        expect(amr_data_feed_import_log.error_messages).to eq AmrReadingData::ERROR_UNABLE_TO_PARSE_FILE
      end
    end

    describe 'creates multiple warnings if required' do
      it 'for missing mpan mprn' do
        reading_data_second[:mpan_mprn] = nil
        reading_data_third[:mpan_mprn] = nil
        expect { ProcessAmrReadingData.new(amr_reading, amr_data_feed_import_log).perform }.to change { AmrDataFeedReading.count }.by(1).and change { AmrReadingWarning.count }.by(2)

        first_warning = AmrReadingWarning.find_by(reading_date: reading_data_second[:reading_date].to_s)
        expect(first_warning.warning.to_sym).to be :missing_mpan_mprn
        expect(first_warning.warning_message).to eq AmrReadingData::WARNINGS[:missing_mpan_mprn]
        expect(first_warning.readings).to match_array reading_data_second[:readings]
        expect(first_warning.reading_date).to eq reading_data_second[:reading_date].to_s

        second_warning = AmrReadingWarning.find_by(reading_date: reading_data_third[:reading_date].to_s)
        expect(second_warning.warning.to_sym).to be :missing_mpan_mprn
        expect(second_warning.warning_message).to eq AmrReadingData::WARNINGS[:missing_mpan_mprn]
        expect(second_warning.readings).to match_array reading_data_third[:readings]
        expect(second_warning.reading_date).to eq reading_data_third[:reading_date].to_s
      end
    end
  end
end

  # WARNINGS = {
  #   blank_readings: 'Some days have blank readings',
  #   missing_readings: 'Some days have missing readings',
  #   missing_mpan_mprn: 'Mpan or MPRN field is missing',
  #   missing_reading_date: 'Reading date is missing',
  #   invalid_reading_date: 'Bad format for a reading data'
  # }.freeze
