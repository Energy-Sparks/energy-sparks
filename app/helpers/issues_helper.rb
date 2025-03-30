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

  def issueable_icon(issueable)
    return '' if issueable.nil?
    if issueable.is_a?(Symbol)
      fa_icon(Issue.issueable_images[issueable])
    else
      fa_icon(Issue.issueable_image(issueable))
    end
  end
end
