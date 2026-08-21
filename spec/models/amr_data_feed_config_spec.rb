# frozen_string_literal: true

require 'rails_helper'

describe AmrDataFeedConfig do
  context 'when validating' do
    it { expect(build(:amr_data_feed_config)).to be_valid }

    context 'with positional index' do
      it {
        expect(build(:amr_data_feed_config, positional_index: true, row_per_reading: false,
                                            period_field: nil)).not_to be_valid
      }

      it {
        expect(build(:amr_data_feed_config, positional_index: true, row_per_reading: false,
                                            period_field: 'Period')).not_to be_valid
      }

      it {
        expect(build(:amr_data_feed_config, positional_index: true, row_per_reading: true,
                                            period_field: nil)).not_to be_valid
      }

      it { expect(build(:amr_data_feed_config, :with_positional_index)).to be_valid }
    end

    context 'with serial lookup' do
      it { expect(build(:amr_data_feed_config, lookup_by_serial_number: true, msn_field: nil)).not_to be_valid }
      it { expect(build(:amr_data_feed_config, :with_serial_number_lookup)).to be_valid }
      it { expect(build(:amr_data_feed_config, msn_field: 'MSN')).to be_valid }
    end
  end

  describe '#reading_indexes' do
    subject(:amr_data_feed_config) { create(:amr_data_feed_config) }

    it 'correctly identifies the indexes of the half-hourly readings' do
      expect(amr_data_feed_config.reading_indexes).to eq (3..(3 + 47)).to_a
    end

    context 'with jumbled order of columns' do
      subject(:amr_data_feed_config) do
        create(:amr_data_feed_config, reading_fields: reading_fields, header_example: header_example)
      end

      let(:reading_fields) do
        '[00:30],[01:00],[01:30],[02:00],[02:30],[03:00],[03:30],[04:00],[04:30],[05:00],[05:30],[06:00],[06:30],[07:00],[07:30],[08:00],[08:30],[09:00],[09:30],[10:00],[10:30],[11:00],[11:30],[12:00],[12:30],[13:00],[13:30],[14:00],[14:30],[15:00],[15:30],[16:00],[16:30],[17:00],[17:30],[18:00],[18:30],[19:00],[19:30],[20:00],[20:30],[21:00],[21:30],[22:00],[22:30],[23:00],[23:30],[24:00]'.split(',')
      end
      let(:header_example) do
        'ID,Date,Location,Type,PostCode,Units,Total Units,[00:30],[01:30],[01:00],[02:00],[02:30],[03:00],[03:30],[04:00],[04:30],[05:00],[05:30],[06:00],[06:30],[07:00],[07:30],[08:00],[08:30],[09:00],[09:30],[10:00],[10:30],[11:00],[11:30],[12:00],[12:30],[13:00],[13:30],[14:00],[14:30],[15:00],[15:30],[16:00],[16:30],[17:00],[17:30],[18:00],[18:30],[19:00],[19:30],[20:00],[20:30],[21:00],[21:30],[22:00],[22:30],[23:00],[23:30],[24:00],M1_Code1,M1_Code2'
      end

      it 'correctly identifies the indexes of the half-hourly readings when out of order' do
        expect(amr_data_feed_config.reading_indexes).to eq [7, 9, 8] + (10..(10 + 44)).to_a
      end
    end
  end

  describe '#reading_status_indexes' do
    subject(:amr_data_feed_config) { create(:amr_data_feed_config) }

    def reading_times
      Array.new(48) do |hh|
        TimeOfDay.time_of_day_from_halfhour_index(hh).to_s
      end
    end

    it 'returns empty array when no values' do
      expect(amr_data_feed_config.reading_status_indexes).to be_empty
    end

    context 'when single status field for whole day' do
      subject(:amr_data_feed_config) do
        create(:amr_data_feed_config, :with_single_status_field)
      end

      it 'correctly identifies the reading status indexes' do
        expect(amr_data_feed_config.reading_status_indexes).to eq([3])
      end

      it 'correctly identifies the reading indexes' do
        expect(amr_data_feed_config.reading_indexes).to eq (4..(4 + 47)).to_a
      end
    end

    context 'when status field per reading' do
      subject(:amr_data_feed_config) do
        create(:amr_data_feed_config, :with_half_hourly_status_fields)
      end

      it 'correctly identifies the reading indexes' do
        expect(amr_data_feed_config.reading_indexes).to eq((0..47).map { |i| 3 + (i * 2) })
      end

      it 'correctly identifies the reading status indexes' do
        expect(amr_data_feed_config.reading_status_indexes).to eq((0..47).map { |i| 4 + (i * 2) })
      end
    end

    context 'with status field per reading and repeated column names' do
      subject(:amr_data_feed_config) do
        reading_fields = Array.new(48) { |i| TimeOfDay.time_of_day_from_halfhour_index(i).to_s }
        header_example = (%w[Name MPRN Date] + reading_fields.zip(Array.new(48, 'Type')).flatten).join(',')
        create(:amr_data_feed_config,
               :with_half_hourly_status_fields,
               reading_status_fields: ['Type'],
               reading_fields:,
               header_example:)
      end

      it 'correctly identifies the reading indexes' do
        expect(amr_data_feed_config.reading_indexes).to eq((0..47).map { |i| 3 + (i * 2) })
      end

      it 'correctly identifies the reading status indexes' do
        expect(amr_data_feed_config.reading_status_indexes).to eq((0..47).map { |i| 4 + (i * 2) })
      end
    end

    context 'with repeated names across readings and status' do
      subject(:amr_data_feed_config) do
        fields = Array.new(48) { |i| "HH#{i + 1}" }
        header_example = (%w[Name MPRN Date] + fields + ['Total'] + fields).join(',')
        create(:amr_data_feed_config,
               :with_half_hourly_status_fields,
               reading_status_fields: fields,
               reading_fields: fields,
               repeated_names: true,
               header_example:)
      end

      it 'correctly identifies the reading indexes' do
        expect(amr_data_feed_config.reading_indexes).to eq((0..47).map { |i| 3 + i })
      end

      it 'correctly identifies the reading status indexes' do
        expect(amr_data_feed_config.reading_status_indexes).to eq((0..47).map { |i| 52 + i })
      end
    end
  end

  describe '.date_from_string_using_date_format' do
    let(:expected_date) { Date.new(2022, 5, 12) }

    context 'when date matches format' do
      it 'parses against format' do
        expect(described_class.date_from_string_using_date_format('12/05/2022', '%d/%m/%Y')).to eq(expected_date)
        expect(described_class.date_from_string_using_date_format('2022-05-12', '%Y-%m-%d')).to eq(expected_date)
      end
    end

    context 'when date doesnt match format' do
      it 'defaults to Date.parse' do
        expect(described_class.date_from_string_using_date_format('12/05/2022', '%d-%m-%Y')).to eq(expected_date)
        expect(described_class.date_from_string_using_date_format('2022-05-12',
                                                                  '%d %b %Y %H:%M:%S')).to eq(expected_date)
      end

      it 'parses dates that would be misinterpreted by Date.strptime' do
        expect(described_class.date_from_string_using_date_format('12-05-2022', '%Y-%m-%d')).to eq(expected_date)
        expect(described_class.date_from_string_using_date_format('12/05/2022', '%Y/%m/%d')).to eq(expected_date)
        expect(described_class.date_from_string_using_date_format('12/05/22', '%d/%m/%Y')).to eq(expected_date)
        expect(described_class.date_from_string_using_date_format('12-05-22', '%d-%m-%Y')).to eq(expected_date)
      end
    end
  end
end
