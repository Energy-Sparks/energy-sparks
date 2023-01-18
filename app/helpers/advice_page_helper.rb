module AdvicePageHelper
  def advice_page_path(school, advice_page, tab = :insights)
    polymorphic_path([tab, school, :advice, advice_page.key.to_sym])
  end

  def chart_start_month_year(date = Time.zone.today)
    month_year(date.last_month - 1.year)
  end

  def chart_end_month_year(date = Time.zone.today)
    month_year(date.last_month)
  end

  def month_year(date)
    I18n.t('date.month_names')[date.month] + " " + date.year.to_s
  end

  def advice_baseload_high?(val)
    val > 0.0
  end
end
