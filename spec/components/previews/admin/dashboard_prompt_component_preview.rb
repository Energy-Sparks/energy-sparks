# frozen_string_literal: true

module Admin
  class DashboardPromptComponentPreview < ViewComponent::Preview
    def default
      render Admin::DashboardPromptComponent.new(user: User.admin.first)
    end
  end
end
