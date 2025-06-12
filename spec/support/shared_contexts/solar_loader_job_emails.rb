RSpec.shared_context 'when sending solar loader job emails' do
  let!(:admin)        { create(:admin) }
  let(:start_date)    { nil }
  let(:end_date)      { nil }

  let(:email)         { ActionMailer::Base.deliveries.last }
  # access to html might change depending on type of email sent, e.g. mail vs make_bootstrap_mail
  # this returns the html body as a string
  let(:email_body)    { email.html_part.body.decoded }
  let(:email_subject) { email.subject }
  # parse the html string into something we can match against
  let(:html_email)    { Capybara::Node::Simple.new(email_body) }

  let(:meters_url) { school_meters_url(installation.meters.first&.school || installation.school, host: 'localhost') }
end
