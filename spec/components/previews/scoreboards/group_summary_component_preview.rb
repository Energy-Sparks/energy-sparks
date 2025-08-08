class Scoreboards::GroupSummaryComponentPreview < ViewComponent::Preview
  def example(slug: 19)
    school_group = SchoolGroup.find(slug)

    scored_schools = school_group.scored_schools # all scored schools
    featured_school = scored_schools.first # most points
    podium = Podium.create(school: featured_school, scoreboard: school_group)
    render(Scoreboards::GroupSummaryComponent.new(school_group: school_group, podium: podium, user: User.admin.first))
  end
end
