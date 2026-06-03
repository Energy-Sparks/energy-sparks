module Cms
  class PageSummaryComponentPreview < ViewComponent::Preview
    def default
      render(Cms::PageSummaryComponent.new(current_user: User.school_admin.first, page: Cms::Page.first))
    end

    def admin
      page = Cms::Page.where(published: false).first || Cms::Page.first
      render(Cms::PageSummaryComponent.new(current_user: User.admin.first, page:))
    end
  end
end
