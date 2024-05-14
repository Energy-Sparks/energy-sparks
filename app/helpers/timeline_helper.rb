module TimelineHelper
  def title_for_month(month, year)
    if month == Date.current.strftime('%-m') && year == Date.current.strftime('%Y')
      month_title = t('timeline.this_month')
      year_title = ''
    else
      month_title = t('date.month_names')[month.to_i]
      year_title = year
    end
    content = content_tag(:span) do
      content_tag(:strong, month_title, class: '') + ' ' +
        content_tag(:span, year_title, class: 'text-muted')
    end
    content
  end
end
