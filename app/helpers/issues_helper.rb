module IssuesHelper
  def issue_type_icon(issue_type, count = 0)
    colour = count > 0 ? Issue.issue_type_classes[issue_type.to_sym] : 'grey-light'
    fa_icon("#{Issue.issue_type_image(issue_type)} text-#{colour}")
  end

  def issue_type_icons(issues, hide_empty: false, label: '')
    counts = []
    icons = []
    Issue.issue_types.each_key do |issue_type|
      count = issues.is_a?(Hash) ? issues[issue_type] : issues.for_issue_types(issue_type).status_open.count
      unless count == 0 && hide_empty
        counts << pluralize(count, issue_type.to_s)
        icons << issue_type_icon(issue_type, count)
      end
    end
    if icons.any?
      content_tag(:span, title: counts.join(' & '), data: { toggle: 'tooltip' }) do
        icons.prepend(label) if label
        icons.join(' ').html_safe
      end
    end
  end

  def issue_type_image(issue_type)
    image = issue_type.to_sym == :note ? 'sticky-note-regular.png' : 'exclamation-circle-solid.png'
    image_tag "email/#{image}", width: '20px', height: '20px'
  end

  def issue_type_count(label, count)
    "#{label} #{content_tag(:span, count, class: %w[badge badge-secondary])}".html_safe
  end

  def issueable_icon(issueable)
    return '' if issueable.nil?

    if issueable.is_a?(Symbol)
      fa_icon(Issue.issueable_images[issueable])
    else
      fa_icon(Issue.issueable_image(issueable))
    end
  end

  def review_date_badge(issue, label: true, humanise: true, classes: '')
    if issue.review_date.nil? || issue.review_date >= 1.week.from_now
      colour = 'bg-white text-dark'
      title = issue.review_date.nil? ? 'No next review date set' : 'Next review date is over a week away'
    elsif issue.review_date > Time.zone.today
      colour = 'bg-warning text-white'
      title = 'Next review date approaching soon'
    else
      colour = 'bg-danger text-white'
      title = 'Next review date is overdue'
    end
    text = issue.review_date ? short_dates(issue.review_date, humanise:) : 'No date set'

    content_tag(:div, class: ['badge badge-pill font-weight-normal', colour, classes], title: title, data: { toggle: 'tooltip' }) do
      "#{'Next review • ' if label}#{text}".html_safe
    end
  end
end
