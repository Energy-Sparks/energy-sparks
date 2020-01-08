require 'rails_helper'

RSpec.describe "school", type: :system do

  let(:school_name) { 'Oldfield Park Infants'}
  let!(:school)   { create(:school, :with_school_group, name: school_name)}
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
        click_on('Enable alerts')
        expect(page.current_path).to eq school_contacts_path(school)
        expect(page).to have_content 'Alerts enabled for Arthur Boggitt'
      end

       it 'allows me to add a contact for an existing user' do
        visit school_contacts_path(school)

        select teacher.name, from: 'Enable alerts for:'
        click_button 'Next'
        expect(find_field('Email address').value).to eq teacher.email
        click_on('Enable alerts')
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

  describe 'when logged in as a teacher' do

    before(:each) do
      sign_in(teacher)
    end

    it 'lets me sign up for alerts' do

      expect(teacher.contact).to be_nil
      visit school_path(school)

      click_on('My alerts')

      expect(find_field('Email address').value).to eq teacher.email
      click_button 'Enable alerts'

      teacher.reload
      expect(teacher.contact).to_not be_nil

      click_on 'My alerts'

      click_on 'Disable alerts'

      teacher.reload
      expect(teacher.contact).to be_nil

    end
  end
end
