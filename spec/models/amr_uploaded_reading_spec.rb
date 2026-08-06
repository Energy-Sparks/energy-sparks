require 'rails_helper'

describe AmrUploadedReading do
  let(:amr_data_feed_config) { build(:amr_data_feed_config, date_format: '%e %b %Y %H:%M:%S') }
  let(:amr_uploaded_reading) { AmrUploadedReading.new(file_name: 'file', amr_data_feed_config: amr_data_feed_config) }

  it 'knows when it is valid, even if the dates are not in the correct format' do
    expect(amr_uploaded_reading.valid?).to be true
  end

  describe 'knows when it is invalid' do
    it 'with missing file_name' do
      amr_uploaded_reading.file_name = nil
      expect(amr_uploaded_reading.valid?).to be false
    end
  end

  describe '.delete_old_records!' do
    context 'with an old record' do
      before { create(:amr_uploaded_reading, created_at: 3.years.ago) }

      it 'deletes the record' do
        expect { described_class.delete_old_records! }.to change(described_class, :count).by(-1)
      end
    end

    context 'with an newer unused record' do
      before { create(:amr_uploaded_reading, created_at: 3.years.ago + 1.day) }

      it 'does nothing' do
        expect { described_class.delete_old_records! }.not_to change(described_class, :count)
      end
    end
  end
end
