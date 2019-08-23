require 'rails_helper'

RSpec.describe "school", type: :system do

  let(:school_name) { 'Oldfield Park Infants'}
  let!(:school) { create(:school, name: school_name)}
  let!(:teacher)  { create(:staff, school: school)}


  describe 'when logged in as a school admin' do

    let!(:school_admin)  { create(:school_admin, school: school)}

    before(:each) do
      sign_in(school_admin)
      visit root_path
      click_on 'Manage alert contacts'
    end

    describe 'no contacts' do

       it 'allows me to add a new one' do
        visit school_contacts_path(school)

        click_on('Enable alerts for an email or phone number')
        fill_in('Name', with: 'Arthur Boggitt')
        fill_in('Email address', with: 'arthur@boggithall.test')
        click_on('Save')
        expect(page.current_path).to eq school_contacts_path(school)
        expect(page).to have_content 'Alerts enabled for Arthur Boggitt'
      end

       it 'allows me to add a contact for an existing user' do
        visit school_contacts_path(school)

        select teacher.name, from: 'Enable alerts for:'
        click_button 'Next'
        expect(find_field('Email address').value).to eq teacher.email
        click_on('Save')
        expect(page).to have_content "Alerts enabled for #{teacher.name}"

        contact = school.contacts.last
        expect(contact.user).to eq(teacher)
        expect(contact.email_address).to eq(teacher.email)
        expect(contact.name).to eq(teacher.name)
      end
    end
  end

  describe 'when logged in as an admin' do

    let!(:admin)  { create(:admin) }

    before(:each) do
      sign_in(admin)
    end

    describe 'existing contacts' do
      let!(:contact) { create(:contact_with_name_email, school: school) }
      it 'shows me the contacts on the page' do
        visit school_contacts_path(school)
        expect(page).to have_content contact.name

        click_on('Reports')
        click_on('Alert subscribers')
        expect(page).to have_content contact.name

      end
    end
  end
end
