require 'rails_helper'

RSpec.describe 'school', type: :system do
  let(:school_name) { 'Oldfield Park Infants' }
  let!(:school) { create(:school, :with_school_group, name: school_name) }
  let!(:teacher) { create(:staff, school: school) }

  describe 'when logged in as a school admin' do
    let!(:school_admin) { create(:school_admin, school: school) }

    before do
      sign_in(school_admin)
      visit root_path
      click_on 'Manage alert contacts'
    end

    it 'allows me to add a contact for an existing user' do
      expect(page).not_to have_content('Standalone contacts')

      find("#enable_alerts_#{teacher.id}").click
      expect(find_field('Email address').value).to eq teacher.email

      click_on('Enable alerts')
      expect(page).to have_content "Alerts enabled for #{teacher.name}"

      contacts = school.contacts
      expect(contacts.pluck(:user_id)).to include(teacher.id)
      expect(contacts.pluck(:email_address)).to include(teacher.email)
      expect(contacts.pluck(:name)).to include(teacher.name)
    end
  end

  describe 'when logged in as an admin' do
    let!(:admin) { create(:admin) }

    before do
      sign_in(admin)
    end

    describe 'existing standalone contacts' do
      let!(:contact) { create(:contact_with_name_email, school: school) }

      it 'shows me the contacts on the page' do
        visit school_contacts_path(school)
        expect(page).to have_content('Standalone contacts')
        expect(page).to have_content contact.name

        click_on('Reports')
        click_on('Alert subscribers')
        expect(page).to have_content contact.name
      end

      it 'allows contacts to be edited' do
        visit school_contacts_path(school)

        click_on('Edit')
        fill_in 'Mobile phone number', with: '01122333444'
        click_on('Update details')
        expect(page).to have_content contact.name

        contact.reload
        expect(contact.mobile_phone_number).to eq('01122333444')
      end

      it 'allows contacts to be deleted' do
        visit school_contacts_path(school)
        expect do
          click_on('Delete')
        end.to change(Contact, :count).by(-1)
      end
    end

    describe 'existing account contacts' do
      let!(:contact) { create(:contact_with_name_email, user: teacher, school: school) }

      it 'allows contacts to be edited' do
        visit school_contacts_path(school)

        click_on('Edit phone number')
        fill_in 'Mobile phone number', with: '01122333444'
        click_on('Update details')
        expect(page).to have_content teacher.name

        contact.reload
        expect(contact.mobile_phone_number).to eq('01122333444')
      end

      it 'allows contacts to be deleted' do
        visit school_contacts_path(school)
        expect do
          click_on('Disable alerts')
        end.to change(Contact, :count).by(-1)
      end
    end

    describe 'existing standalone contacts' do
      let!(:contact) { create(:contact_with_name_email, school: school) }

      it 'shows me the contacts on the page' do
        visit school_contacts_path(school)

        expect(page).to have_content('Standalone contacts')
        expect(page).to have_content contact.name

        click_on('Reports')
        click_on('Alert subscribers')
        expect(page).to have_content contact.name
      end

      it 'allows existing contacts to be edited' do
        visit school_contacts_path(school)

        click_on('Edit')
        expect(page).not_to have_content('Preferred language')

        fill_in 'Mobile phone number', with: '01122333444'
        click_on('Update details')
        expect(page).to have_content contact.name

        contact.reload
        expect(contact.mobile_phone_number).to eq('01122333444')
      end

      it 'allows existing contacts to be deleted' do
        visit school_contacts_path(school)
        expect do
          click_on('Delete')
        end.to change(Contact, :count).by(-1)
      end
    end
  end
end
