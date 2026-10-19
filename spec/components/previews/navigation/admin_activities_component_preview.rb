# frozen_string_literal: true

module Navigation
  class AdminActivitiesComponentPreview < ViewComponent::Preview
    def default
      render(Navigation::AdminActivitiesComponent.new)
    end
  end
end
