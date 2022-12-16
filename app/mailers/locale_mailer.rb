class LocaleMailer < ApplicationMailer
  def self.with(params)
    locales = params[:locales] || I18n.available_locales
    MethodRepeater.new(locales.map {|l| super(params.merge(locale: l))})
  end

  def make_bootstrap_mail_for(**args)
    locale = params[:locale]
    make_bootstrap_mail_for_locale(locale, args) if args[:to].any?
  end

  def email_addresses_for_locale(users)
    locale = params[:locale]
    users.select {|u| u.preferred_locale == locale}.map(&:email)
  end
end
