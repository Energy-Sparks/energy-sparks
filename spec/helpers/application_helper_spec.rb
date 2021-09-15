require 'rails_helper'

describe ApplicationHelper do

  describe '.up_downify' do

    it 'adds an up arrow icon for positive starts' do
      expect(helper.up_downify('+10%')).to include('<i')
      expect(helper.up_downify('+10%')).to include('up')
    end

    it 'adds an up arrow icon for increased' do
      expect(helper.up_downify('increased')).to include('<i')
      expect(helper.up_downify('increased')).to include('up')
    end

    it 'adds a down arrow icon for negative starts' do
      expect(helper.up_downify('-10%')).to include('<i')
      expect(helper.up_downify('-10%')).to include('down')
    end

    it 'adds a down arrow icon for decreased' do
      expect(helper.up_downify('decreased')).to include('<i')
      expect(helper.up_downify('decreased')).to include('down')
    end

    it 'does not add other strings' do
      expect(helper.up_downify('hello')).to_not include('<i')
      expect(helper.up_downify('hello + goodbye')).to_not include('<i')
    end

  end

  describe 'last signed in helper' do
    it 'shows a message if a user has never signed in' do
      expect(display_last_signed_in_as(build(:user))).to eq 'Never signed in'
    end

    it 'shows the last time as user signed in' do
      last_sign_in_at = DateTime.new(2001,2,3,4,5,6)
      expect(display_last_signed_in_as(build(:user, last_sign_in_at: last_sign_in_at))).to eq nice_date_times(last_sign_in_at)
    end
  end

  describe 'other_field_name' do
    it 'makes a name from wordy category title' do
      expect(helper.other_field_name('Local authority')).to eq('OTHER_LA')
    end
    it 'makes a name from abbreviated category title' do
      expect(helper.other_field_name('MAT')).to eq('OTHER_MAT')
    end
  end

  describe 'human_counts' do
    it 'shows 0 as once' do
      expect(helper.human_counts([])).to eq('no times')
    end
    it 'shows 1 as once' do
      expect(helper.human_counts([1])).to eq('once')
    end
    it 'shows 2 as twice' do
      expect(helper.human_counts([1,2])).to eq('twice')
    end
    it 'shows more than 2 as several times' do
      expect(helper.human_counts([1,2,3])).to eq('several times')
    end
  end
end
