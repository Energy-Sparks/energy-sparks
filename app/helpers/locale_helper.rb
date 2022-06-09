module LocaleHelper
  def t_attr(model_name, attribute_name, suffix = nil)
    key = "activerecord.attributes.#{model_name}.#{attribute_name}"
    key.concat('_', suffix.to_s) if suffix
    t(key)
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
