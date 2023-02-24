class LocaleMailer < ApplicationMailer
  def self.with_user_locales(users:, **args)
    I18n.available_locales.each do |locale|
      locale_users = users_for_locale(users, locale)
      if locale_users.any?
        yield self.with(**args, locale: locale, users: locale_users)
      end
    end
  end

  def self.with_contact_locale(contact:, **args)
    yield self.with(**args, school: contact.school, email_address: contact.email_address, locale: contact.preferred_locale)
  end

  def self.users_for_locale(users, locale)
    users.select {|u| u.preferred_locale.to_sym == locale.to_sym}
  end

  def for_each_locale(locales)
    locales.map { |locale| I18n.with_locale(locale) { yield } }
  end

  # send with locale if preferred locales are enabled
  def make_bootstrap_mail(*args)
    I18n.with_locale(active_locale(locale_param)) do
      super(*args)
    end
  end

  def active_locale(locale)
    EnergySparks::FeatureFlags.active?(:emails_with_preferred_locale) ? locale : :en
  end

  def active_locales(locales)
    EnergySparks::FeatureFlags.active?(:emails_with_preferred_locale) ? locales : [:en]
  end

  def locale_param
    params[:locale] || :en
  end
end
