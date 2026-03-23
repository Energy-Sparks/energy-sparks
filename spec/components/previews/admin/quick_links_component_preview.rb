# frozen_string_literal: true

module Admin
  class QuickLinksComponentPreview < ViewComponent::Preview
    def example
      user = User.where(role: 'admin').first
      render Admin::QuickLinksComponent.new(current_user: user)
    end
  end
end
