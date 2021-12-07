module HelpPageHelper
  def help_page_for_feature(feature)
    help_page = HelpPage.find_by_feature(feature)
    return help_page if help_page.present? && (help_page.published? || current_user && current_user.admin?)
  rescue ActiveRecord::StatementInvalid
    # feature not yet added to enum in HelpPage model
  end

  def link_to_help_for_feature(feature, title: "Help", css: '')
    help_page = help_page_for_feature(feature)
    if help_page
      link_to help_path(help_page), class: css do
        title
      end
    end
  end
end
