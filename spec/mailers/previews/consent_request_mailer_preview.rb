class ConsentRequestMailerPreview < ActionMailer::Preview
  def request_consent
    ConsentRequestMailer.with(school: School.first, users: School.first.users, locale: locale).request_consent
  end

  private

  def locale
    locale = @params['locale'].presence || 'en'
  end
end
