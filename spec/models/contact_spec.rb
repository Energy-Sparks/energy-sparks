require 'rails_helper'
require "cancan/matchers"

describe Contact do

  let(:school){ create(:school) }
  let(:other_school){ create(:school) }

  describe 'email validation' do
    let!(:existing_contact){ create(:contact, school: school, name: 'test', email_address: 'test@example.com') }

    it 'checks for unique email address within the school' do
      expect(build(:contact, school: school, name: 'test', email_address: 'test@example.com')).to_not be_valid
      expect(build(:contact, school: school, name: 'test', email_address: 'blah@example.com')).to be_valid
      expect(build(:contact, school: other_school, name: 'test', email_address: 'test@example.com')).to be_valid
    end
  end

  describe 'phone validation' do
    let!(:existing_contact){ create(:contact, school: school, name: 'test', mobile_phone_number: '01122333444') }

    it 'checks for unique phone number within the school' do
      expect(build(:contact, school: school, name: 'test', mobile_phone_number: '01122333444')).to_not be_valid
      expect(build(:contact, school: school, name: 'test', mobile_phone_number: '01122999888')).to be_valid
      expect(build(:contact, school: other_school, name: 'test', mobile_phone_number: '01122333444')).to be_valid
    end
  end

end


