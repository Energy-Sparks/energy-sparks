module IssuesHelper
  def issue_type_icon(issue_type)
    fa_icon("#{Issue.issue_type_image(issue_type)} text-secondary")
  end

  def issueable_icon(issueable)
    return '' if issueable.nil?
    if issueable.is_a?(Symbol)
      fa_icon(Issue.issueable_images[issueable])
    else
      fa_icon(Issue.issueable_image(issueable))
    end
  end

  def issues_toggle_link(params, issue_type, issueable:)
    polymorphic_path([:filter, :admin, issueable, Issue], user: params[:user], issue_types: toggle_item(params[:issue_types].dup, issue_type))
  end

  def issues_index_link(issueable, issue_types, query = {})
    polymorphic_path([:admin, issueable, Issue], query.merge(issue_types: issue_types))
  end
end
