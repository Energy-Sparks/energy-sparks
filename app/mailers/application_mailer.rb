class ApplicationMailer < ActionMailer::Base
  default from: 'Energy Sparks <hello@energysparks.uk>'
  layout 'mailer'

  before_action :set_title

  # send with locale if preferred locales are enabled
  def make_bootstrap_mail_for_locale(*args)
    I18n.with_locale(active_locale) do
      make_bootstrap_mail(*args)
    end
  end

  # ensure that emails are all in English for the moment
  def make_bootstrap_mail_en(*args)
    I18n.with_locale(:en) do
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

  def email_addresses_for_locale(users)
    locale = params[:locale]
    users.select {|u| u.preferred_locale.to_sym == locale.to_sym}.map(&:email)
  end

  def active_locale
    if EnergySparks::FeatureFlags.active?(:emails_with_preferred_locale)
      params[:locale] || :en
    else
      :en
    end
  end
end
