require 'rails_helper'

describe AmrReadingData do





  describe 'handles when reading date is a date' do
    let(:date_format) { '%Y-%m-%d' }
    let(:amr_reading) { AmrReadingData.new(reading_data: [
                                                      { :mpan_mprn => 123, :reading_date => Date.parse('2019-01-01'), readings: Array.new(48, '0.0')  },
                                                      { :mpan_mprn => 123, :reading_date => Date.parse('2019-01-02'), readings: Array.new(48, '0.0')  },
                                                      ],
                                            date_format: date_format) }

    it 'knows when it is valid' do
      expect(amr_reading.valid?).to be true
    end
  end

  describe 'handles when reading date is a string' do

    let(:date_format) { '%e %b %Y %H:%M:%S' }
    let(:amr_reading) { AmrReadingData.new(reading_data: [
                                                      { :mpan_mprn => 123, :reading_date => '2019-01-01', readings: Array.new(48, '0.0')  },
                                                      { :mpan_mprn => 123, :reading_date => '2019-01-02', readings: Array.new(48, '0.0')  },
                                                      ],
                                            date_format: date_format) }

    it 'knows when it is valid, even if the dates are not in the correct format' do
      expect(amr_reading.valid?).to be true
    end

    describe 'knows when it is invalid' do
      it 'with missing mpan_mprn' do
        amr_reading.reading_data.first.delete(:mpan_mprn)

        expect(amr_reading.valid?).to be false
        expect(amr_reading.errors.messages[:reading_data]).to include(AmrReadingData::ERROR_MISSING_MPAN)
      end

      it 'with missing reading date' do
        amr_reading.reading_data.second.delete(:reading_date)

        expect(amr_reading.valid?).to be false
        expect(amr_reading.errors.messages[:reading_data]).to include(AmrReadingData::ERROR_MISSING_READING_DATE)
      end

      it 'with missing readings' do
        amr_reading.reading_data.first[:readings].shift

        expect(amr_reading.valid?).to be false
        expect(amr_reading.errors.messages[:reading_data]).to include(AmrReadingData::ERROR_MISSING_READINGS)
      end

      it 'with missing readings (as nil)' do
        readings = amr_reading.reading_data.first[:readings]
        readings[readings.size - 1] = nil

        amr_reading.reading_data.first[:readings] = readings

        expect(amr_reading.valid?).to be false
        expect(amr_reading.errors.messages[:reading_data]).to include(AmrReadingData::ERROR_MISSING_READINGS)
      end

      it 'when dates are not quite the right format' do
        bad_date = 'AAAAAA'
        amr_reading.reading_data.first[:reading_date] = bad_date

        expect(amr_reading.valid?).to be false
        expect(amr_reading.errors.messages[:reading_data]).to include(AmrReadingData::ERROR_BAD_DATE_FORMAT % { example: bad_date })
      end
    end
  end
end
