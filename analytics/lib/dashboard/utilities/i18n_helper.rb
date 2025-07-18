class I18nHelper
  def self.adjective(adjective)
    I18n.t("analytics.adjectives.#{adjective}")
  end

  def self.day_name(idx)
    I18n.t("date.day_names")[idx]
  end

  #accepts a holiday type symbol
  def self.holiday(holiday_type)
    I18n.t("analytics.holidays")[holiday_type]
  end

end
