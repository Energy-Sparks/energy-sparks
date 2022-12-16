class ApplicationMailer < ActionMailer::Base
  default from: 'Energy Sparks <hello@energysparks.uk>'
  layout 'mailer'

  before_action :set_title

  # ensure that emails are all in English for the moment
  def make_bootstrap_mail_en(*args)
    I18n.with_locale(:en) do
      make_bootstrap_mail(*args)
    end
  end

  def make_bootstrap_mail_for_locale(locale, *args)
    I18n.with_locale(locale) do
      make_bootstrap_mail(*args)
    end
  end

  def default_url_options
    if Rails.env.production?
      { host: I18n.locale == :cy ? ENV['WELSH_APPLICATION_HOST'] : ENV['APPLICATION_HOST'] }
    else
      super
    end
  end

  def set_title
    @title = params[:title] || ""
  end
end
