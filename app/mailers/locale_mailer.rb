class LocaleMailer
  def self.with(params)
    mailer_class = params.delete(:mailer)
    I18n.available_locales.each do |locale|
      yield mailer_class.with(params.merge(locale: locale))
    end
  end
end
