require 'rails_helper'

RSpec.describe "manage school alert contacts", type: :system do
  let(:school) { create(:school) }
  let(:school2) { create(:school) }

  before(:each) do
    sign_in(user) if user.present?
  end

  context 'as a guest' do
    let(:user) { nil }
    it 'should not be able to visit the alert contacts page and instead redirected to the log in page' do
      visit school_contacts_path(school)
      expect(page.current_path).to eq(new_user_session_path)
    end
  end

  context 'as a pupil' do
    let(:user) { create(:pupil, school: school) }
    it 'should not be able to visit the alert contacts page and instead redirected to the schools pupil page' do
      visit school_contacts_path(school)
      expect(page.current_path).to eq(pupils_school_path(school))
    end
  end

  context 'as staff' do
    let(:user)   { create(:staff, school: school) }
    it 'should be able to visit the alert contacts page' do
      visit school_contacts_path(school)
      expect(page.current_path).to eq(school_path(school))
    end
  end

  context 'as school admin' do
    let(:user) { create(:school_admin, school: school) }
    it 'should be able to visit the alert contacts page and enter a new contact' do
      visit school_contacts_path(school)
      expect(page.current_path).to eq(school_contacts_path(school))
      expect(page).to have_content("#{school.name} Alert Contacts")
      expect(page).to have_content("Energy Sparks alerts:")
      expect(page).to have_content("Account contacts")
      expect(page).not_to have_content("Professor Yaffle")
      click_on "Enable alerts for an email or phone number"
      expect(page.current_path).to eq(new_school_contact_path(school))
      fill_in 'Name', with: 'Professor Yaffle'
      fill_in 'Email address', with: 'yaffle@example.com'
      fill_in 'Mobile phone number', with: '078912345678'
      click_on "Enable alert"
      expect(page.current_path).to eq(school_contacts_path(school))
      expect(page).to have_content("Professor Yaffle")
      click_on "Edit"
      fill_in 'Name', with: 'Prof Yaffle'
      click_on "Update details"
      expect(page.current_path).to eq(school_contacts_path(school))
      expect(page).not_to have_content("Professor Yaffle")
      expect(page).to have_content("Prof Yaffle")
    end
  end

  context 'as admin' do
    let(:user)          { create(:admin) }
    it 'should be able to visit the alert contacts page and enter a new contact' do
      visit school_contacts_path(school)
      expect(page.current_path).to eq(school_contacts_path(school))
      expect(page).to have_content("#{school.name} Alert Contacts")
      expect(page).to have_content("Energy Sparks alerts:")
      expect(page).to have_content("Account contacts")
      expect(page).not_to have_content("Professor Yaffle")
      click_on "Enable alerts for an email or phone number"
      expect(page.current_path).to eq(new_school_contact_path(school))
      fill_in 'Name', with: 'Professor Yaffle'
      fill_in 'Email address', with: 'yaffle@example.com'
      fill_in 'Mobile phone number', with: '078912345678'
      click_on "Enable alert"
      expect(page.current_path).to eq(school_contacts_path(school))
      expect(page).to have_content("Professor Yaffle")
      click_on "Edit"
      fill_in 'Name', with: 'Prof Yaffle'
      click_on "Update details"
      expect(page.current_path).to eq(school_contacts_path(school))
      expect(page).not_to have_content("Professor Yaffle")
      expect(page).to have_content("Prof Yaffle")
    end
  end
end
