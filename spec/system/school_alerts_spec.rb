require 'rails_helper'

RSpec.describe "school alerts", type: :system do

  let(:alerts_button) { 'Alerts' }
  let(:school_name) { 'Oldfield Park Infants'}
  let!(:school)     { create(:school, name: school_name)}
  let!(:admin)      { create(:user, role: 'admin')}

  describe 'when logged in' do
    before(:each) do
      sign_in(admin)
      visit root_path
      expect(page).to have_content  'Sign Out'
      click_on('Schools')
      expect(page).to have_content  "Participating Schools"
    end

    describe 'shows alerts' do

      let!(:alert) { create(:alert, school: school) } 
      it 'shows me a page with all possible alerts' do
        expect(alert.alert_type.category).to be_in AlertType.categories.keys
        expect(alert.alert_type.sub_category).to be_in AlertType.sub_categories.keys
        expect(alert.school).to eq school
        click_on(school_name)
        expect(page).to have_content alerts_button
        click_on alerts_button
        expect(page).to have_content alert.alert_type.title
        expect(page).to have_content 'No one allocated'
      end

      it 'shows me a page with an allocated contact' do
        contact = create(:contact_with_name_email)
        alert.contacts << contact
        click_on(school_name)
        expect(page).to have_content alerts_button
        click_on alerts_button
        expect(page).to have_content alert.alert_type.title
        expect(page).to have_content contact.name
      end
    end

    describe 'existing contacts' do
      let!(:contact) { create(:contact_with_name_email, school: school) }
      let!(:alert) { create(:alert, school: school, contacts: [contact]) } 

      it 'shows me the contacts on the page' do
        click_on(school_name)
        expect(page).to have_content alerts_button
        click_on alerts_button
        expect(page).to have_content contact.name
      end
    end
  end
end
