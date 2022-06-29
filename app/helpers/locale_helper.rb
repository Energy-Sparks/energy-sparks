module LocaleHelper
  def locale_field_has_errors(form, field, locale)
    I18n.locale == locale && form.object.errors.include?(field)
  end

  def locale_field_errors(form, field)
    form.object.errors[field].join(' and ')
  end

  def t_field(sym, locale)
    "#{sym}_#{Mobility.normalize_locale(locale)}".to_sym
  end

  def t_params(fields, locales = I18n.available_locales)
    locales.map do |locale|
       fields.map do |field|
         t_field(field, locale)
       end
    end.flatten
  end
end
