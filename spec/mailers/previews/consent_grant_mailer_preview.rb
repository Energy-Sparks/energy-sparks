class ConsentGrantMailerPreview < ActionMailer::Preview
  def email_consent
    ConsentGrantMailer.with(consent_grant: ConsentGrant.first).email_consent
  end
end
