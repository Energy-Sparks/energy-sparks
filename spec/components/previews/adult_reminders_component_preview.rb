class AdultRemindersComponentPreview < ViewComponent::Preview
  def example(slug: nil, title: 'Reminders')
    school = slug ? School.find(slug) : School.active.sample
    user = User.admin.first
    component = AdultRemindersComponent.new(school: school, user: user)
    component.with_title do
      "#{title} (#{school.name})"
    end
    render(component)
  end
end
