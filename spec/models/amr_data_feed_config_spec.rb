require 'rails_helper'

describe AmrDataFeedReading do
  let(:amr_data_feed_config) { create(:amr_data_feed_config) }

  context 'when validating' do
    it { expect(build(:amr_data_feed_config)).to be_valid }

    context 'with positional index' do
      it { expect(build(:amr_data_feed_config, positional_index: true, row_per_reading: false, period_field: nil)).not_to be_valid }
      it { expect(build(:amr_data_feed_config, positional_index: true, row_per_reading: false, period_field: 'Period')).not_to be_valid }
      it { expect(build(:amr_data_feed_config, positional_index: true, row_per_reading: true, period_field: nil)).not_to be_valid }
      it { expect(build(:amr_data_feed_config, :with_positional_index)).to be_valid }
    end

    context 'with serial lookup' do
      it { expect(build(:amr_data_feed_config, lookup_by_serial_number: true, msn_field: nil)).not_to be_valid }
      it { expect(build(:amr_data_feed_config, :with_serial_number_lookup)).to be_valid }
      it { expect(build(:amr_data_feed_config, msn_field: 'MSN')).to be_valid }
    end
  end

  describe '#array_of_reading_indexes' do
    it 'correctly identifies the indexes of the reading records' do
      expect(amr_data_feed_config.array_of_reading_indexes).to eq (3..3 + 47).to_a
    end

    context 'with jumbled order of columns' do
      let(:reading_fields) { '[00:30],[01:00],[01:30],[02:00],[02:30],[03:00],[03:30],[04:00],[04:30],[05:00],[05:30],[06:00],[06:30],[07:00],[07:30],[08:00],[08:30],[09:00],[09:30],[10:00],[10:30],[11:00],[11:30],[12:00],[12:30],[13:00],[13:30],[14:00],[14:30],[15:00],[15:30],[16:00],[16:30],[17:00],[17:30],[18:00],[18:30],[19:00],[19:30],[20:00],[20:30],[21:00],[21:30],[22:00],[22:30],[23:00],[23:30],[24:00]'.split(',') }

      let(:header_example) { 'ID,Date,Location,Type,PostCode,Units,Total Units,[00:30],[01:30],[01:00],[02:00],[02:30],[03:00],[03:30],[04:00],[04:30],[05:00],[05:30],[06:00],[06:30],[07:00],[07:30],[08:00],[08:30],[09:00],[09:30],[10:00],[10:30],[11:00],[11:30],[12:00],[12:30],[13:00],[13:30],[14:00],[14:30],[15:00],[15:30],[16:00],[16:30],[17:00],[17:30],[18:00],[18:30],[19:00],[19:30],[20:00],[20:30],[21:00],[21:30],[22:00],[22:30],[23:00],[23:30],[24:00],M1_Code1,M1_Code2'}

      let(:amr_data_feed_config) { create(:amr_data_feed_config, reading_fields: reading_fields, header_example: header_example) }

      it 'correctly identifies the indexes of the reading records even when in a funny order' do
        expect(amr_data_feed_config.array_of_reading_indexes).to eq [7, 9, 8] + (10..10 + 44).to_a
      end
    end
  end
end
