require 'rails_helper'

describe ComparisonsHelper do
  describe '#comparison_page_exists?' do
    it 'returns true if controller exists' do
      expect(comparison_page_exists?(:baseload_per_pupil)).to be true
    end

    it 'returns false if controller does not exist' do
      expect(comparison_page_exists?(:never_ever_going_to_exist)).to be false
    end
  end

  describe '#holiday_name' do
    it 'works for easter' do
      expect(holiday_name(:easter, Date.new(2023, 4, 1), Date.new(2023, 4, 15))).to eq('Easter 2023')
    end

    it 'works for xmas' do
      expect(holiday_name(:xmas, Date.new(2023, 12, 20), Date.new(2024, 1, 2), partial: true)).to \
        eq('Xmas 2023/2024 (partial)')
    end
  end

  describe '#csv_colgroups' do
    it 'add blanks' do
      expect(csv_colgroups([{ label: '' }, { label: 'kwh', colspan: 3 }])).to eq(['', 'kwh', '', ''])
    end
  end
end
