require 'rails_helper'

describe ComparisonsHelper do
  describe '#comparison_page_exists?' do
    it 'returns true if controller exists' do
      expect(comparison_page_exists?(:baseload_per_pupil)).to be_truthy
    end

    it 'returns false if controller does not exist' do
      expect(comparison_page_exists?(:never_ever_going_to_exist)).to be_falsey
    end
  end
end
