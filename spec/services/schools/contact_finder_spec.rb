require 'rails_helper'

RSpec.describe Schools::ContactFinder do

  let!(:school)           { create(:school) }
  let!(:user)             { create(:user, school: school, email: 'blah@example.com')}

  let!(:service)          { Schools::ContactFinder.new(school) }

  context 'when contact is connected to user' do
    let!(:contact) { create(:contact, name: 'Contact 1', school: school, user: user, email_address: 'totall@different.org')}

    it 'should find the contact by association' do
      expect(service.contact_for(user)).to eq(contact)
    end
  end

  context 'when contact is not connected to user' do
    let!(:contact) { create(:contact, name: 'Contact 1', school: school, user: nil, email_address: user.email)}

    it 'should find the contact by email' do
      expect(service.contact_for(user)).to eq(contact)
    end
  end

  context 'when contact does not have user id or same email' do
    let!(:contact) { create(:contact, name: 'Contact 1', school: school, user: nil, email_address: 'totall@different.org')}

    it 'should return nil' do
      expect(service.contact_for(user)).to be_nil
    end
  end
end
