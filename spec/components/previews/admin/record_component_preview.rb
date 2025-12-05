module Admin
  class RecordComponentPreview < ViewComponent::Preview
    def default
      render Admin::RecordComponent.new(Observation.activity.sample, current_user: User.admin.first)
    end
  end
end
