require 'rails_helper'

RSpec.describe "school alert subscription events", type: :system do
  let!(:school) { create(:school) }
  let!(:user)   { create(:user, role: :admin) }
  let!(:alert)               { create(:alert, school: school) }
  let!(:contact)             { create(:contact_with_name_email, school: school) }
  let!(:alert_type_rating)   { create :alert_type_rating, alert_type: alert.alert_type, rating_from: 1, rating_to: 6, email_active: true}
  let!(:content_version)     { create :alert_type_rating_content_version, alert_type_rating: alert_type_rating }
  let(:service) { Alerts::GenerateSubscriptionEvents.new(school, alert) }

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
    expect(email.html_part.body.to_s).to include(content_version.email_title)

    click_on('View', match: :first)
    expect(page).to have_content(content_version.email_title)
  end
end
