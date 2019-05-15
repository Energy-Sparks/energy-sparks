require 'rails_helper'

describe AlertTypeRatingContentVersion do

  describe 'timing validation' do

    it 'validates that the end_date is on or after the start_date' do
      content_version = AlertTypeRatingContentVersion.new(
        find_out_more_start_date: Date.new(2019, 01, 20),
        find_out_more_end_date: Date.new(2019, 01, 19),
      )
      content_version.timings_are_correct(:find_out_more)
      expect(content_version.errors[:find_out_more_end_date]).to include('must be on or after start date')
    end

    it 'allows the end date to be the same as the start date' do
      content_version = AlertTypeRatingContentVersion.new(
        find_out_more_start_date: Date.new(2019, 01, 20),
        find_out_more_end_date: Date.new(2019, 01, 20),
      )
      content_version.timings_are_correct(:find_out_more)
      expect(content_version.errors[:find_out_more_end_date]).to be_empty
    end
  end

end
