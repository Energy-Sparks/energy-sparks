require 'rails_helper'

describe ApplicationHelper do

  describe '.up_downify' do

    it 'adds a down arrow icon for negative starts' do
      expect(helper.up_downify('+10%')).to include('<i')
      expect(helper.up_downify('+10%')).to include('up')
    end

    it 'adds an up arrow icon for positive starts' do
      expect(helper.up_downify('-10%')).to include('<i')
      expect(helper.up_downify('-10%')).to include('down')
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
end
