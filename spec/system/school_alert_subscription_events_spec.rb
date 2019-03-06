require 'rails_helper'

RSpec.describe "school alert subscription events", type: :system do
  let!(:school) { create(:school) }
  let!(:user)   { create(:user, role: :admin) }
  let!(:alert)               { create(:alert, school: school) }
  let!(:contact)             { create(:contact_with_name_email, school: school) }
  let!(:alert_subscription)  { create(:alert_subscription, alert_type: alert.alert_type, school: school, contacts: [contact]) }
  let(:service) { Alerts::GenerateSubscriptionEvents.new(school) }

  before(:each) do
    sign_in(user)
    visit root_path
  end

  it 'should show a helpful message if no events' do
    click_on(school.name)
    click_on('Alert subscription events')
    expect(page.has_content?('There are no alert subscription events')).to be true
  end

  it 'allows the user to send all pending emails' do
    service.perform
    click_on(school.name)
    click_on('Alert subscription events')
    expect(page.has_content?('Pending')).to be true
    click_on('Send pending emails now')

    email = ActionMailer::Base.deliveries.last

    expect(email.subject).to include('Energy Sparks alerts')
    expect(email.html_part.body.to_s).to include(alert.title)
  end
end
