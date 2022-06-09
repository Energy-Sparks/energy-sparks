module TranslationHelper
  def t_language(locale)
    t('language_name', locale: locale)
  end

  def t_field(sym, locale)
    "#{sym}_#{Mobility.normalize_locale(locale)}".to_sym
  end

  def t_label(str, locale)
    "#{str} (#{t_language(locale)})"
  end
end
