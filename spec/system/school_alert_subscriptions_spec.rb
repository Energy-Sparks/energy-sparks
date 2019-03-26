require 'rails_helper'

RSpec.describe "school alerts subscriptions", type: :system do

  let(:alert_subscriptions_button) { 'Manage alert subscriptions' }
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

    describe 'shows alert subscriptions' do
      let!(:alert_subscription) { create(:alert_subscription, school: school) }
      it 'shows me a page with all possible alerts' do
        expect(alert_subscription.alert_type.fuel_type).to be_in AlertType.fuel_types.keys
        expect(alert_subscription.alert_type.sub_category).to be_in AlertType.sub_categories.keys
        expect(alert_subscription.school).to eq school
        click_on(school_name)
        click_on alert_subscriptions_button
        expect(page).to have_content alert_subscription.alert_type.title
        expect(page).to have_content 'No one allocated'
      end

      it 'shows me a page with an allocated contact' do
        contact = create(:contact_with_name_email)
        alert_subscription.contacts << contact
        click_on(school_name)
        click_on alert_subscriptions_button
        expect(page).to have_content alert_subscription.alert_type.title
        expect(page).to have_content contact.name

        click_on('Reports')
        click_on('Alert subscribers')
        expect(page).to have_content contact.name
      end
    end

    describe 'existing contacts' do
      let!(:contact) { create(:contact_with_name_email, school: school) }
      let!(:alert_subscription) { create(:alert_subscription, school: school, contacts: [contact]) }

      it 'shows me the contacts on the page' do
        click_on(school_name)
        click_on alert_subscriptions_button
        expect(page).to have_content contact.name
      end
    end
  end
end
