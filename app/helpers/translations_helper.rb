module TranslationsHelper
  def t_language(locale)
    t('language_name', locale: locale)
  end

  def t_field(sym, locale)
    "#{sym}_#{Mobility.normalize_locale(locale)}".to_sym
  end

  def t_label(str, locale)
    "#{str} (#{t_language(locale)})"
  end

  def t_params(locales, fields)
    locales.map do |locale|
       fields.map do |field|
         t_field(field, locale)
       end
    end.flatten
  end
end
