module IssuesHelper
  def issue_type_icon(issue_type)
    fa_icon("#{Issue.issue_type_image(issue_type)} text-secondary")
  end

  def issueable_icon(issueable)
    issueable ? fa_icon(Issue.issueable_image(issueable)) : ''
  end
end
