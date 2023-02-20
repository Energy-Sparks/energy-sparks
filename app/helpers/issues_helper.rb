module IssuesHelper
  def issue_type_icon(issue_type, count = 0)
    colour = count > 0 ? Issue.issue_type_classes[issue_type.to_sym] : "secondary"
    fa_icon("#{Issue.issue_type_image(issue_type)} text-#{colour}")
  end

  def issue_type_icons(issues, hide_empty: false)
    counts = []
    icons = []
    Issue.issue_types.each_key do |issue_type|
      count = issues.for_issue_types(issue_type).count
      counts << pluralize(count, issue_type.to_s) unless count == 0 && hide_empty
      icons << issue_type_icon(issue_type, count) unless count == 0 && hide_empty
    end
    content_tag(:span, title: counts.join(" & "), data: { toggle: "tooltip" }) do
      icons.join(" ").html_safe
    end
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
