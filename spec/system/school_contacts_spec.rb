require 'rails_helper'

RSpec.describe "school", type: :system do

  let(:school_name) { 'Oldfield Park Infants'}
  let!(:school) { create(:school, name: school_name)}
  let!(:admin)  { create(:user, role: 'admin')}

  describe 'when logged in' do
    before(:each) do
      sign_in(admin)
      visit root_path
      expect(page.has_content? 'Sign Out').to be true
      click_on('Schools')
      expect(page.has_content? "Participating Schools").to be true
    end

    describe 'no contacts' do
      it 'shows me an empty contacts page' do
        click_on(school_name)
        expect(page.has_content? "Contacts").to be true
        click_on "Contacts"
      end
    end

    describe 'existing contacts' do
      let!(:contact) { create(:contact_with_name_email) }
      it 'shows me the contacts on the page' do
        click_on(school_name)
        expect(page.has_content? "Contacts").to be true
        click_on "Contacts"
         expect(page.has_content? contact.name).to be true
      end
    end
  end
end
