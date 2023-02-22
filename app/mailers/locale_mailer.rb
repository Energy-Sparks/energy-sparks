class LocaleMailer < ApplicationMailer
  def self.with_locales(params)
    I18n.available_locales.each do |locale|
      yield self.with(params.merge(locale: locale))
    end
  end

  # send with locale if preferred locales are enabled
  def make_bootstrap_mail(*args)
    I18n.with_locale(active_locale) do
      super(*args)
    end
  end

  def email_addresses_for_locale(users)
    users.select {|u| u.preferred_locale.to_sym == locale.to_sym}.map(&:email)
  end

  def active_locale
    EnergySparks::FeatureFlags.active?(:emails_with_preferred_locale) ? locale : :en
  end

  def locale
    params[:locale] || :en
  end
end
