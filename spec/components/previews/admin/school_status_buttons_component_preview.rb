# frozen_string_literal: true

module Admin
  class SchoolStatusButtonsComponentPreview < ViewComponent::Preview
    def default
      component(School.active.sample)
    end

    def sharing_within_group
      component(School.data_sharing_within_group.sample)
    end

    def sharing_private
      component(School.data_sharing_private.sample)
    end

    def not_active
      component(School.inactive.sample)
    end

    def not_processing_data
      component(School.where(process_data: false).sample)
    end

    private

    def component(school)
      render Admin::SchoolStatusButtonsComponent.new(school:, user: User.admin.first)
    end
  end
end
