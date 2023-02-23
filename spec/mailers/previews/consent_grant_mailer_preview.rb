class ConsentGrantMailerPreview < ActionMailer::Preview
  def email_consent
    ConsentGrantMailer.with(users: [ConsentGrant.first.user], consent_grant: ConsentGrant.first).email_consent
  end
end
