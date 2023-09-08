module LocaleMailerHelper
  def for_each_locale(locales)
    locales.map { |locale| I18n.with_locale(locale) { yield } }
  end
end
