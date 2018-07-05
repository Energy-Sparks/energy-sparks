require 'rails_helper'

RSpec.describe "school", type: :system do

  let(:school_name) { 'Oldfield Park Infants'}
  let!(:school) { create(:school, name: school_name)}
  let!(:admin)  { create(:user, role: 'admin')}

  describe 'when logged in' do
    before(:each) do
      sign_in(admin)
      visit root_path
      expect(page).to have_content 'Sign Out'
      click_on('Schools')
      expect(page).to have_content "Participating Schools"
    end

    describe 'no contacts' do
      it 'shows me an empty contacts page' do
        visit school_contacts_path(school)
        expect(page).to have_content "No contacts are currently set up for this school."
      end

       it 'allows me to add a new one' do
        visit school_contacts_path(school)
        expect(page).to have_content "No contacts are currently set up for this school."

        click_on('New Contact')
        fill_in('Name', with: 'Arthur Boggitt')
        fill_in('Email address', with: 'arthur@boggithall.test')
        click_on('Save')
        expect(page.current_path).to eq school_contacts_path(school)
        expect(page).to have_content 'Arthur Boggitt was successfully created'
      end
    end

    describe 'existing contacts' do
      let!(:contact) { create(:contact_with_name_email, school: school) }
      it 'shows me the contacts on the page' do
        visit school_contacts_path(school)
        expect(page).to have_content contact.name
      end
    end
  end
end
