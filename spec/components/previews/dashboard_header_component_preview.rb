class DashboardHeaderComponentPreview < ViewComponent::Preview
  def default
    render(DashboardHeaderComponent.new(school: School.active.sample(1).first))
  end
end
