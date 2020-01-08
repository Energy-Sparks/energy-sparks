require 'rails_helper'

describe AmrUploadedReading do
  let(:amr_data_feed_config) { build(:amr_data_feed_config, date_format:  '%e %b %Y %H:%M:%S') }
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
end
