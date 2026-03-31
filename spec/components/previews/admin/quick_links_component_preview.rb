# frozen_string_literal: true

module Admin
  class QuickLinksComponentPreview < ViewComponent::Preview
    def default
      user = User.admin.first
      render Admin::QuickLinksComponent.new(user: user)
    end
  end
end
