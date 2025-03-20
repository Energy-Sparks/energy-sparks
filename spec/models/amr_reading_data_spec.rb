require 'rails_helper'

describe AmrReadingData, :aggregate_failures do
  subject(:amr_reading_data) do
    described_class.new(amr_data_feed_config: amr_data_feed_config, reading_data: reading_data)
  end

  let(:amr_data_feed_config) { create(:amr_data_feed_config, date_format: date_format) }

  let(:date_format) { '%Y-%m-%d' }
  let(:reading_data) { [] }

  shared_examples 'it is valid' do
    let(:valid_readings) { 2 }
    it 'validates correctly' do
      expect(amr_reading_data.valid?).to be true
      expect(amr_reading_data.valid_reading_count).to be valid_readings
      expect(amr_reading_data.warnings?).to be false
      expect(amr_reading_data.warnings).to eq([])
    end
  end

  shared_examples 'it is not valid' do
    let(:valid_readings) { 0 }
    let(:warnings) { 2 }
    it 'validates correctly' do
      expect(amr_reading_data.valid?).to be false
      expect(amr_reading_data.valid_reading_count).to eq valid_readings
      expect(amr_reading_data.warnings?).to be true
      expect(amr_reading_data.warnings.count).to eq warnings
    end
  end

  shared_examples 'it has a warning' do
    let(:valid_readings) { 1 }
    let(:warnings) { 1 }
    let(:warning_type) { :missing_readings }

    it 'validates correctly' do
      expect(amr_reading_data.valid?).to be true
      expect(amr_reading_data.valid_reading_count).to eq valid_readings
      expect(amr_reading_data.warnings?).to be true
      expect(amr_reading_data.warnings.count).to eq warnings
      expect(amr_reading_data.warnings.first[:warnings]).to include(warning_type)
    end
  end

  def create_one_invalid_reading(mpan_mprn: '1234050000001', reading_date: '2022-01-01', readings: Array.new(48, '0.0'))
    [
      { mpan_mprn:, reading_date:, readings: }, # invalid
      {
        mpan_mprn: '1234050000000',
        reading_date: '2022-01-01',
        readings: Array.new(48, '0.0')
      }
    ]
  end

  describe 'with valid data' do
    describe 'when reading date is a Date' do
      let(:reading_data) do
        mpan_mprn = '1234050000000'
        readings = Array.new(48, '0.0')
        [
          { mpan_mprn:, readings:, reading_date: Date.parse('2019-01-01') },
          { mpan_mprn:, readings:, reading_date: Date.parse('2019-01-02') }
        ]
      end

      it_behaves_like 'it is valid'
    end

    describe 'when reading date is a String' do
      let(:reading_data) do
        mpan_mprn = '1234050000000'
        readings = Array.new(48, '0.0')
        [
          { mpan_mprn:, readings:, reading_date: '2019-01-01' },
          { mpan_mprn:, readings:, reading_date: '2019-01-02' }
        ]
      end

      it_behaves_like 'it is valid'
    end

    describe 'when data formats dont match, but can be parsed' do
      let(:date_format) { '%y-%m-%d' }

      let(:reading_data) do
        mpan_mprn = '1234050000000'
        readings = Array.new(48, '0.0')
        [
          { mpan_mprn:, readings:, reading_date: '2022-01-01' },
          { mpan_mprn:, readings:, reading_date: '2022-01-02' }
        ]
      end

      it_behaves_like 'it is valid'
    end
  end

  describe 'when every row is invalid' do
    let(:reading_data) do
      mpan_mprn = nil
      readings = Array.new(48, '0.0')
      [
        { mpan_mprn:, readings:, reading_date: '2019-01-01' },
        { mpan_mprn:, readings:, reading_date: '2019-01-02' }
      ]
    end

    it_behaves_like 'it is not valid'
  end

  describe 'when there are invalid rows' do
    context 'with missing mpan_mprn' do
      let(:reading_data) do
        create_one_invalid_reading(mpan_mprn: nil)
      end

      it_behaves_like 'it has a warning' do
        let(:warning_type) { :missing_mpan_mprn }
      end
    end

    context 'when mpan_mprns are invalid' do
      let(:reading_data) do
        create_one_invalid_reading(mpan_mprn: invalid_mpan_mprn)
      end

      ['1.23405E+12', '+1234050000000', '1234.50000000', 1234.50000000].each do |mpan|
        context "with #{mpan}" do
          let(:invalid_mpan_mprn) { mpan }

          it_behaves_like 'it has a warning' do
            let(:warning_type) { :invalid_non_numeric_mpan_mprn }
          end
        end
      end
    end

    context 'with duplicate rows' do
      let(:reading_data) do
        mpan_mprn = '1234050000000'
        readings = Array.new(48, '0.0')
        [
          { mpan_mprn:, readings:, reading_date: '2019-01-01' },
          { mpan_mprn:, readings:, reading_date: '2019-01-01' }
        ]
      end

      it_behaves_like 'it has a warning' do
        let(:warnings) { 1 }
        let(:warning_type) { :duplicate_reading }
      end
    end

    context 'with missing reading date' do
      let(:reading_data) do
        create_one_invalid_reading(reading_date: nil)
      end

      it_behaves_like 'it has a warning' do
        let(:warning_type) { :missing_reading_date }
      end
    end

    context 'with reading date in the future' do
      let(:reading_data) do
        create_one_invalid_reading(reading_date: Time.zone.today + 1)
      end

      it_behaves_like 'it has a warning' do
        let(:warning_type) { :future_reading_date }
      end
    end

    context 'with unparseable date' do
      let(:reading_data) do
        create_one_invalid_reading(reading_date: 'AAAAA')
      end

      it_behaves_like 'it has a warning' do
        let(:warning_type) { :invalid_reading_date }
      end
    end

    context 'with missing readings' do
      let(:reading_data) do
        create_one_invalid_reading(readings: missing_readings)
      end

      let(:missing_readings) { Array.new(47, 0.0) }

      it_behaves_like 'it has a warning' do
        let(:warning_type) { :missing_readings }
      end

      context 'when format is row per reading and missing threshold is higher' do
        let(:amr_data_feed_config) do
          create(:amr_data_feed_config,
                 row_per_reading: true,
                 date_format: date_format,
                 missing_readings_limit: 1)
        end

        it_behaves_like 'it is valid'
      end

      context 'when format is row per reading and merged is allowed' do
        let(:amr_data_feed_config) do
          create(:amr_data_feed_config,
                 row_per_reading: true,
                 date_format: date_format,
                 allow_merging: true)
        end

        it_behaves_like 'it is valid'
      end

      context 'with missing as nil' do
        let(:missing_readings) { Array.new(47, 0.0) << nil }

        it_behaves_like 'it has a warning' do
          let(:warning_type) { :missing_readings }
        end
      end

      context 'with missing as empty string' do
        let(:missing_readings) { Array.new(47, 0.0) << '' }

        it_behaves_like 'it has a warning' do
          let(:warning_type) { :missing_readings }
        end
      end

      context 'with missing as dashes' do
        let(:missing_readings) { Array.new(47, 0.0) << '-' }

        it_behaves_like 'it has a warning' do
          let(:warning_type) { :missing_readings }
        end
      end
    end

    context 'with strict date handling' do
      around do |example|
        ClimateControl.modify FEATURE_FLAG_INCONSISTENT_READING_DATE_FORMAT_WARNING: 'true' do
          example.run
        end
      end

      let(:date_format) { '%d-%m-%y' }

      let(:reading_data) do
        readings = Array.new(48, '0.0')
        [
          { mpan_mprn: '1234050000000', readings:, reading_date: '31-01-22' },
          { mpan_mprn: '1234050000001', readings:, reading_date: '31-01-2022' }
        ]
      end

      it_behaves_like 'it has a warning' do
        let(:warnings) { 1 }
        let(:warning_type) { :inconsistent_reading_date_format }
      end
    end
  end
end
