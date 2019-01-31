require 'rails_helper'

RSpec.describe "school alert subscription events", type: :system do
  let!(:school) { create(:school) }
  let!(:user)   { create(:user, school: school, role: :school_admin) }
  let!(:alert)               { create(:alert, school: school) }
  let!(:contact)             { create(:contact_with_name_email, school: school) }
  let!(:alert_subscription)  { create(:alert_subscription, alert_type: alert.alert_type, school: school, contacts: [contact]) }
  let(:service) { Alerts::GenerateSubscriptionEvents.new(school) }

  before(:each) do
    sign_in(user)
    visit root_path
  end

  it 'should show a helpful message if no events' do
    click_on('Alert subscription events')
    expect(page.has_content?('There are no alert subscription events')).to be true
  end

  it 'should give a message if no alerts' do
    service.perform
    click_on('Alert subscription events')
    expect(page.has_content?('There are no alert subscription events')).to be false
    expect(page.has_content?(contact.name)).to be true
    expect(page.has_content?('pending')).to be true
  end
end
