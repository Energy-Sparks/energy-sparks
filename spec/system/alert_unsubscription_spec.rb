require 'rails_helper'

describe 'Unsubscribing from email alerts' do
  let(:school)               { create(:school) }
  let(:alert)                { create(:alert, :with_run, school: school) }
  let!(:email_contact)       { create(:contact_with_name_email, school: school) }
  let!(:alert_type_rating)   { create :alert_type_rating, alert_type: alert.alert_type, email_active: true }
  let!(:content_version)     { create :alert_type_rating_content_version, alert_type_rating: alert_type_rating, email_title: 'You need to do something!', email_content: 'You really do'}

  before do
    Alerts::GenerateContent.new(school).perform(subscription_frequency: AlertType.frequencies.keys)
  end

  it 'asks for a reason and timing' do
    visit new_email_unsubscription_url(uuid: AlertSubscriptionEvent.first.unsubscription_uuid)
    fill_in 'Reason', with: 'These are not relevant to me'
    choose '6 months'
    click_on 'Submit'

    expect(page).to have_content('Thank you for your feedback')

    unsubscription = AlertTypeRatingUnsubscription.first
    expect(unsubscription.contact).to eq(email_contact)
    expect(unsubscription.alert_type_rating).to eq(alert_type_rating)
    expect(unsubscription.effective_until).to eq(6.months.from_now.to_date)
  end

end
