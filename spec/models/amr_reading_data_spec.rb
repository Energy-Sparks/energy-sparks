require 'rails_helper'

describe AmrReadingData do
  let(:date_format) { '%Y-%m-%d' }

  describe 'handles when reading date is a date' do
    let(:amr_reading) do
      AmrReadingData.new(reading_data: [
                           { :mpan_mprn => '1234050000000', :reading_date => '2019-01-01', readings: Array.new(48, '0.0')  },
                           { :mpan_mprn => '1234050000000', :reading_date => '2019-01-02', readings: Array.new(48, '0.0')  },
                         ],
                                            date_format: date_format)
    end

    it 'knows when it is valid' do
      expect(amr_reading.valid?).to be true
      expect(amr_reading.valid_reading_count).to be 2
      expect(amr_reading.warnings?).to be false
      expect(amr_reading.warnings.count).to be 0
    end
  end

  describe 'handles when reading date is actually a string' do
    let(:amr_reading) do
      AmrReadingData.new(reading_data: [
                           { :mpan_mprn => '1234050000000', :reading_date => '2019-01-01', readings: Array.new(48, '0.0')  },
                           { :mpan_mprn => '1234050000000', :reading_date => '2019-01-02', readings: Array.new(48, '0.0')  },
                         ],
                                            date_format: date_format)
    end

    it 'knows when it is valid' do
      expect(amr_reading.valid?).to be true
      expect(amr_reading.valid_reading_count).to be 2
      expect(amr_reading.warnings?).to be false
      expect(amr_reading.warnings.count).to be 0
    end
  end

  describe 'handles when each row is invalid' do
    let(:amr_reading) do
      AmrReadingData.new(reading_data: [
                           { :mpan_mprn => nil, :reading_date => '2019-01-01', readings: Array.new(48, '0.0') },
                           { :mpan_mprn => nil, :reading_date => '2019-01-02', readings: Array.new(48, '0.0') },
                         ],
                                            date_format: date_format)
    end

    it 'whole file is invalid' do
      expect(amr_reading.valid?).to be false
      expect(amr_reading.valid_reading_count).to be 0
      expect(amr_reading.warnings?).to be true
      expect(amr_reading.warnings.count).to be 2
    end
  end

  describe 'handles when reading date is a string' do
    let(:date_format) { '%Y-%m-%d' }
    let(:amr_reading_data) do
      {
                              reading_data: [
                                { :mpan_mprn => '1234050000000', :reading_date => '2022-01-01', readings: Array.new(48, '0.0')  },
                                { :mpan_mprn => '1234050000000', :reading_date => '2022-01-02', readings: Array.new(48, '0.0')  },
                              ],
                              date_format: date_format
                            }
    end

    it 'knows when it is valid, even if the dates are not in the correct format' do
      amr_reading = AmrReadingData.new(**amr_reading_data)
      expect(amr_reading.valid?).to be true
      expect(amr_reading.valid_reading_count).to be 2
      expect(amr_reading.warnings?).to be false
    end

    describe 'raises warnings for rows' do
      it 'with missing mpan_mprn' do
        amr_reading_data[:reading_data].first.delete(:mpan_mprn)

        amr_reading = AmrReadingData.new(**amr_reading_data)

        expect(amr_reading.valid?).to be true
        expect(amr_reading.warnings?).to be true
        expect(amr_reading.valid_reading_count).to be 1
        expect(amr_reading.warnings.count).to be 1
        expect(amr_reading.warnings.first[:warnings]).to include(:missing_mpan_mprn)
      end

      it 'with invalid non-numeric mpan_mprn' do
        amr_reading_data[:reading_data].first[:mpan_mprn] = '1.23405E+12'
        amr_reading = AmrReadingData.new(**amr_reading_data)
        expect(amr_reading.valid?).to be true
        expect(amr_reading.warnings?).to be true
        expect(amr_reading.valid_reading_count).to be 1
        expect(amr_reading.warnings.count).to be 1
        expect(amr_reading.warnings.first[:warnings]).to include(:invalid_non_numeric_mpan_mprn)

        amr_reading_data[:reading_data].first[:mpan_mprn] = '+1234050000000'
        amr_reading = AmrReadingData.new(**amr_reading_data)
        expect(amr_reading.valid?).to be true
        expect(amr_reading.warnings?).to be true
        expect(amr_reading.valid_reading_count).to be 1
        expect(amr_reading.warnings.count).to be 1
        expect(amr_reading.warnings.first[:warnings]).to include(:invalid_non_numeric_mpan_mprn)

        amr_reading_data[:reading_data].first[:mpan_mprn] = '1234.50000000'
        amr_reading = AmrReadingData.new(**amr_reading_data)
        expect(amr_reading.valid?).to be true
        expect(amr_reading.warnings?).to be true
        expect(amr_reading.valid_reading_count).to be 1
        expect(amr_reading.warnings.count).to be 1
        expect(amr_reading.warnings.first[:warnings]).to include(:invalid_non_numeric_mpan_mprn)

        amr_reading_data[:reading_data].first[:mpan_mprn] = 1234.50000000
        amr_reading = AmrReadingData.new(**amr_reading_data)
        expect(amr_reading.valid?).to be true
        expect(amr_reading.warnings?).to be true
        expect(amr_reading.valid_reading_count).to be 1
        expect(amr_reading.warnings.count).to be 1
        expect(amr_reading.warnings.first[:warnings]).to include(:invalid_non_numeric_mpan_mprn)
      end

      it 'with missing reading date' do
        amr_reading_data[:reading_data].second.delete(:reading_date)
        amr_reading = AmrReadingData.new(**amr_reading_data)

        expect(amr_reading.valid?).to be true
        expect(amr_reading.warnings?).to be true
        expect(amr_reading.valid_reading_count).to be 1
        expect(amr_reading.warnings.count).to be 1
        expect(amr_reading.warnings.first[:warnings]).to include(:missing_reading_date)
      end

      it 'with reading date in the future' do
        amr_reading = AmrReadingData.new(**amr_reading_data.merge(today: Date.new(2018, 1, 1)))

        expect(amr_reading.valid?).to be false
        expect(amr_reading.warnings?).to be true
        expect(amr_reading.valid_reading_count).to be 0
        expect(amr_reading.warnings.count).to be 2
        expect(amr_reading.warnings.first[:warnings]).to include(:future_reading_date)
      end

      it 'with missing readings' do
        amr_reading_data[:reading_data].first[:readings].shift
        amr_reading = AmrReadingData.new(**amr_reading_data)


        expect(amr_reading.valid?).to be true
        expect(amr_reading.warnings?).to be true
        expect(amr_reading.valid_reading_count).to be 1
        expect(amr_reading.warnings.count).to be 1
        expect(amr_reading.warnings.first[:warnings]).to include(:missing_readings)
      end

      it 'with missing readings but with tolerance for 1 missing' do
        amr_reading_data[:reading_data].first[:readings].shift
        amr_reading_data[:missing_reading_threshold] = 1
        amr_reading = AmrReadingData.new(**amr_reading_data)

        expect(amr_reading.valid?).to be true
        expect(amr_reading.warnings?).to be false
      end

      it 'with missing readings (as nil)' do
        readings = amr_reading_data[:reading_data].first[:readings]
        readings[readings.size - 1] = nil

        amr_reading_data[:reading_data].first[:readings] = readings

        amr_reading = AmrReadingData.new(**amr_reading_data)

        expect(amr_reading.valid?).to be true
        expect(amr_reading.warnings?).to be true
        expect(amr_reading.valid_reading_count).to be 1
        expect(amr_reading.warnings.count).to be 1
        expect(amr_reading.warnings.first[:warnings]).to include(:missing_readings)
      end

      it "with missing readings (as \"\")" do
        readings = amr_reading_data[:reading_data].first[:readings]
        readings[readings.size - 1] = ""

        amr_reading_data[:reading_data].first[:readings] = readings

        amr_reading = AmrReadingData.new(**amr_reading_data)

        expect(amr_reading.valid?).to be true
        expect(amr_reading.warnings?).to be true
        expect(amr_reading.valid_reading_count).to be 1
        expect(amr_reading.warnings.count).to be 1
        expect(amr_reading.warnings.first[:warnings]).to include(:missing_readings)
      end

      it "with missing readings (as \"-\")" do
        readings = amr_reading_data[:reading_data].first[:readings]
        readings[readings.size - 1] = "-"

        amr_reading_data[:reading_data].first[:readings] = readings

        amr_reading = AmrReadingData.new(**amr_reading_data)

        expect(amr_reading.valid?).to be true
        expect(amr_reading.warnings?).to be true
        expect(amr_reading.valid_reading_count).to be 1
        expect(amr_reading.warnings.count).to be 1
        expect(amr_reading.warnings.first[:warnings]).to include(:missing_readings)
      end

      it 'when dates are not quite the right format' do
        bad_date = 'AAAAAA'
        amr_reading_data[:reading_data].first[:reading_date] = bad_date

        amr_reading = AmrReadingData.new(**amr_reading_data)

        expect(amr_reading.valid?).to be true
        expect(amr_reading.warnings?).to be true
        expect(amr_reading.valid_reading_count).to be 1
        expect(amr_reading.warnings.count).to be 1
        expect(amr_reading.warnings.first[:warnings]).to include(:invalid_reading_date)
      end

      it 'with reading date in a format that does not match the configuration format' do
        ClimateControl.modify FEATURE_FLAG_INCONSISTENT_READING_DATE_FORMAT_WARNING: 'true' do
          amr_reading_data[:reading_data].first[:reading_date] = '31-01-2022'
          amr_reading_data[:reading_data].second[:reading_date] = '31-01-2022'
          # There should be a warning here where Date.strptime('31-01-2022', '%d-%m-%y')
          # converts to the date 'Wed, 31 Jan 2020' (2020 instead of 2022)
          amr_reading_data[:date_format] = '%d-%m-%y'
          amr_reading = AmrReadingData.new(**amr_reading_data)

          expect(amr_reading.valid?).to be false
          expect(amr_reading.warnings?).to be true
          expect(amr_reading.valid_reading_count).to be 0
          expect(amr_reading.warnings.count).to be 2
          expect(amr_reading.warnings.first[:warnings]).to include(:inconsistent_reading_date_format)
        end
      end

      it 'when there are duplicate rows' do
        amr_reading_data[:reading_data].first[:reading_date] = amr_reading_data[:reading_data].last[:reading_date]

        amr_reading = AmrReadingData.new(**amr_reading_data)

        expect(amr_reading.valid?).to be true
        expect(amr_reading.warnings?).to be true
        expect(amr_reading.valid_reading_count).to be 1
        expect(amr_reading.warnings.count).to be 1
        expect(amr_reading.warnings.first[:warnings]).to include(:duplicate_reading)
      end
    end
  end
end
