module Cms
  class PageSummaryComponent < ApplicationComponent
    def initialize(page:, current_user:, **kwargs)
      super
      @page = page
      @current_user = current_user
    end

    def render?
      @page.published || admin?
    end

    def sections
      admin? ? @page.sections.positioned : @page.sections.published.positioned
    end

    private

    def admin?
      @current_user&.admin?
    end
  end
end
