class ConsentRequestMailerPreview < ActionMailer::Preview
  def request_consent
    ConsentRequestMailer.with(school: School.first, emails: 'test@blah.com').request_consent
  end
end
