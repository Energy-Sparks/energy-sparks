class DashboardHeaderComponent < ApplicationComponent
  attr_reader :school, :title, :intro

  def initialize(school:,
                 audience: :adult,
                 title: 'schools.dashboards.header.title',
                 intro: 'schools.dashboards.header.intro',
                 show_school: true,
                 id: nil, classes: '')
    super(id: id, classes: "#{classes} #{audience}")
    @school = school
    @title = title
    @intro = intro
    @audience = audience
    @show_school = show_school
  end

  def show_school?
    @show_school
  end
end
