require 'rails_helper'

RSpec.describe 'school alert subscription events', type: :system do
  let!(:school)              { create(:school) }
  let!(:user)                { create(:admin) }
  let!(:alert)               { create(:alert, :with_run, school: school) }
  let!(:contact)             { create(:contact_with_name_email, school: school) }
  let!(:alert_type_rating)   { create :alert_type_rating, alert_type: alert.alert_type, rating_from: 1, rating_to: 6, email_active: true}
  let!(:content_version)     { create :alert_type_rating_content_version, alert_type_rating: alert_type_rating }
  let(:service)              { Alerts::GenerateSubscriptions.new(school) }

  before do
    sign_in(user)
    service.perform(subscription_frequency: AlertType.frequencies.keys)
    visit school_path(school)
  end

  it 'allows the user to view details of emails' do
    click_on('Batch reports')
    click_on('Email and SMS reports')
    click_on 'View'

    alert_subscription_event = AlertSubscriptionEvent.find_by(content_version: content_version)
    # Weighting
    expect(page.has_content?(content_version.email_weighting))

    # Priority
    expect(page.has_content?(alert_subscription_event.priority))
  end
end
