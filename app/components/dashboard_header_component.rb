class DashboardHeaderComponent < ApplicationComponent
  attr_reader :school, :title, :intro

  # i18n-tasks-use t('components.dashboard_header.title')
  # i18n-tasks-use t('components.dashboard_header.intro_html')
  def initialize(school:,
                 audience: :adult,
                 title: I18n.t('components.dashboard_header.title'),
                 intro: I18n.t('components.dashboard_header.intro_html'),
                 show_school: true,
                 id: nil, classes: '')
    super(id: id, classes: "#{classes} #{audience}")
    @school = school
    @title = title
    @intro = intro&.html_safe
    @audience = audience
    @show_school = show_school
  end

  def show_school?
    @show_school
  end
end
