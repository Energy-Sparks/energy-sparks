module TimelineHelper
  def title_for_month(month, year)
    if month == Date.current.strftime('%-m') && year == Date.current.strftime('%Y')
      month_title = t('timeline.this_month')
      year_title = ''
    else
      month_title = t('date.month_names')[month.to_i]
      year_title = year
    end
    tag.span do
      tag.strong(month_title, class: '') + ' ' +
        tag.span(year_title, class: 'text-muted')
    end
  end
end
