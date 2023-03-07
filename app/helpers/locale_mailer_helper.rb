module LocaleMailerHelper
  def for_each_locale(locales)
    locales.map { |locale| I18n.with_locale(locale) { yield } }
  end

  def active_locale(locale)
    EnergySparks::FeatureFlags.active?(:emails_with_preferred_locale) ? locale : :en
  end

  def active_locales(locales)
    EnergySparks::FeatureFlags.active?(:emails_with_preferred_locale) ? locales : [:en]
  end
end
