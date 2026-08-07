# frozen_string_literal: true

require 'rails_helper'

describe AmrDataFeedReading do
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
  end
end
