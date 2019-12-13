require 'rails_helper'

describe AmrUploadedReading do

  let(:amr_data_feed_config) { build(:amr_data_feed_config, date_format:  '%e %b %Y %H:%M:%S') }
  let(:amr_uploaded_reading) { AmrUploadedReading.new(
                                                    reading_data: [
                                                      { 'mpan_mprn' => 123, 'reading_date' => '2019-01-01', readings: Array.new(48, '0.0')  },
                                                      { 'mpan_mprn' => 123, 'reading_date' => '2019-01-02', readings: Array.new(48, '0.0')  },
                                                    ],
                                                    amr_data_feed_config: amr_data_feed_config
                                                    )
                                                  }

  it 'knows when it is valid, even if the dates are not in the correct format' do
    amr_uploaded_reading.validate
    expect(amr_uploaded_reading.valid?(:validate_reading_data)).to be true

  end

  describe 'knows when it is invalid' do
    it 'with missing mpan_mprn' do
      amr_uploaded_reading.reading_data.first.delete('mpan_mprn')

      expect(amr_uploaded_reading.valid?(:validate_reading_data)).to be false
      expect(amr_uploaded_reading.errors.messages[:base]).to include(AmrUploadedReading::ERROR_MISSING_MPAN)

    end

    it 'with missing reading date' do
      amr_uploaded_reading.reading_data.second.delete('reading_date')

      expect(amr_uploaded_reading.valid?(:validate_reading_data)).to be false
      expect(amr_uploaded_reading.errors.messages[:base]).to include(AmrUploadedReading::ERROR_MISSING_READING_DATE)
    end

    it 'with missing readings' do
      amr_uploaded_reading.reading_data.first['readings'].shift

      expect(amr_uploaded_reading.valid?(:validate_reading_data)).to be false
      expect(amr_uploaded_reading.errors.messages[:base]).to include(AmrUploadedReading::ERROR_MISSING_READINGS)
    end

    it 'with missing readings (as nil)' do
      readings = amr_uploaded_reading.reading_data.first['readings']
      readings[readings.size - 1] = nil

      amr_uploaded_reading.reading_data.first['readings'] = readings

      expect(amr_uploaded_reading.valid?(:validate_reading_data)).to be false
      expect(amr_uploaded_reading.errors.messages[:base]).to include(AmrUploadedReading::ERROR_MISSING_READINGS)
    end

    it 'when dates are not quite the right format' do
      bad_date = 'AAAAAA'
      amr_uploaded_reading.reading_data.first['reading_date'] = bad_date

      expect(amr_uploaded_reading.valid?(:validate_reading_data)).to be false
      expect(amr_uploaded_reading.errors.messages[:base]).to include(AmrUploadedReading::ERROR_BAD_DATE_FORMAT % { example: bad_date })
    end
  end
end
