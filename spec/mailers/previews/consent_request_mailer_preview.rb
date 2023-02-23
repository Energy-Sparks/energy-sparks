class ConsentRequestMailerPreview < ActionMailer::Preview
  def request_consent
    ConsentRequestMailer.with(school: School.first, users: School.first.users).request_consent
  end
end
