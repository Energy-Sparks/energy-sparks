class ConsentRequestMailerPreview < ActionMailer::Preview
  def request_consent
    ConsentRequestMailer.with(school: School.first, users: [User.first]).request_consent
  end
end
