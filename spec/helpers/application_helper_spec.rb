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
end
