require 'rails_helper'

module Amr
  describe ProcessAmrReadingData do
    subject(:service) { ProcessAmrReadingData.new(amr_data_feed_config, amr_data_feed_import_log) }

    let!(:amr_data_feed_config) { create(:amr_data_feed_config) }
    let!(:amr_data_feed_import_log) { create(:amr_data_feed_import_log, amr_data_feed_config: amr_data_feed_config) }
    let(:reading_data_first)        { { :mpan_mprn => '123', :reading_date => Date.parse('2019-01-01'), readings: Array.new(48, '0.0'), amr_data_feed_config_id: amr_data_feed_config.id } }
    let(:reading_data_second)       { { :mpan_mprn => '123', :reading_date => Date.parse('2019-01-02'), readings: Array.new(48, '0.0'), amr_data_feed_config_id: amr_data_feed_config.id } }
    let(:reading_data_third)        { { :mpan_mprn => '123', :reading_date => Date.parse('2019-01-03'), readings: Array.new(48, '0.0'), amr_data_feed_config_id: amr_data_feed_config.id } }
    let(:reading_data_warning)      { { :mpan_mprn => '1234567890123', :reading_date => Date.parse('2019-01-03'), readings: Array.new(40, '0.0'), amr_data_feed_config_id: amr_data_feed_config.id, warnings: [:missing_readings] } }
    let(:valid_reading_data)        { [reading_data_first, reading_data_second, reading_data_third] }

    it 'processes a valid amr reading data' do
      expect { service.perform(valid_reading_data, [])}.to change(AmrDataFeedReading, :count).by(3)
      expect(amr_data_feed_import_log.error_messages).to be_blank
      expect(amr_data_feed_import_log.amr_reading_warnings).to be_empty
    end

    describe 'creates a warning if required' do
      it 'creates a warning if required' do
        school = create(:school)
        meter = create(:electricity_meter, school: school, mpan_mprn: 1234567890123)
        expect { service.perform(valid_reading_data, [reading_data_warning])}.to change(AmrDataFeedReading, :count).by(3).and change(AmrReadingWarning, :count).by(1)

        first_warning = AmrReadingWarning.first

        expect(first_warning.warning_symbols).to include :missing_readings
        expect(first_warning.readings).to match_array reading_data_warning[:readings]
        expect(first_warning.reading_date).to eq reading_data_warning[:reading_date].to_s
        expect(first_warning.school).to eq school
        expect(first_warning.fuel_type).to eq meter.meter_type
      end
    end
  end
end
