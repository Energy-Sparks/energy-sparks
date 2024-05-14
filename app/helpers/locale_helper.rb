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

  def t_fuels_as_sentence(fuels)
    fuels.map { |fuel| I18n.t('common.' + fuel.to_s).downcase }.to_sentence
  end

  def t_attached_links(obj, field, char = ' | ', locales = I18n.available_locales)
    output = locales.collect do |locale|
      link_to_if(obj.send("#{field}_#{locale}").attached?, I18n.t("languages.#{locale}"), obj.send("#{field}_#{locale}")).html_safe
    end
    safe_join output, char
  end

  def t_period(period)
    I18n.t("date.calendar_period.#{period}", default: '')
  end

  def t_day(day)
    I18n.t('date.day_names')[Date.parse(day).wday]
  rescue
    I18n.t("date.other.#{day}", default: '')
  end

  def t_month(month)
    I18n.t('date.month_names')[month.to_i]
  end

  def t_role(role)
    I18n.t("role.#{role}", default: '')
  end
end
