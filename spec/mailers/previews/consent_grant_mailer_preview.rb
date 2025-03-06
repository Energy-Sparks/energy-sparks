class ConsentGrantMailerPreview < ActionMailer::Preview
  def email_consent
    ConsentGrantMailer.with(users: [ConsentGrant.first.user], consent_grant: ConsentGrant.first, locale: locale).email_consent
  end

  private

  def locale
    @params['locale'].present? ? @params['locale'] : 'en'
  end
end
