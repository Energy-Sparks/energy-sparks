class ConsentRequestMailerPreview < ActionMailer::Preview
  def request_consent
    ConsentRequestMailer.with(school: School.first, users: [User.first], locales: [:en]).request_consent
  end
end
