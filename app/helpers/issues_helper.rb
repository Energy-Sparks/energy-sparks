module IssuesHelper
  def issue_type_icon(issue)
    fa_icon(issue.issue? ? 'exclamation-circle text-secondary' : 'sticky-note text-secondary')
  end

  def issueable_icon(issueable)
    fa_icon(Issue.issueable_image(issueable))
  end
end
