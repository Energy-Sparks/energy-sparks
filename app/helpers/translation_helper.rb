module TranslationHelper
  def t_day(day)
    I18n.t('date.day_names')[Date.parse(day).wday]
  end
end
